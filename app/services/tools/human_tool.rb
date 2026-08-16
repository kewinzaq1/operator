module Tools
  class HumanTool
    def initialize(business, client: Providers.humans)
      @business = business
      @client = client
    end

    def request_help!(agent_run:, task:, expertise:, budget:, context: nil, deadline: 2.hours.from_now)
      quote_payload = @client.request_feasibility(task: task, expertise: expertise, context: context)
      quote_id = quote_payload["id"]
      priced = @client.get_feasibility_request(quote_id)
      cost = @client.quoted_cost(priced).to_d

      escalation = @business.human_escalations.create!(
        agent_run: agent_run,
        provider: "terac",
        task: task,
        expertise: expertise,
        status: "quoted",
        quoted_cost: cost,
        budget: budget,
        external_id: quote_id,
        deadline: deadline,
        provenance: {
          "feasibility_request" => quote_payload,
          "quote" => priced,
          "matched_expert" => expertise
        }
      )

      return escalation if cost > budget.to_d

      opportunity = @client.create_opportunity(
        title: task.to_s.truncate(80),
        description: [ task, context ].compact.join("\n\n"),
        num_participants: 1,
        estimated_duration_minutes: 20,
        filters: []
      )
      opportunity_id = opportunity["id"]
      @client.launch_opportunity(opportunity_id)
      submissions = @client.get_submissions(opportunity_id)
      record = Array(submissions["data"] || submissions["submissions"] || submissions).first || {}
      result = record["result"] || record["response"] || Humans::DemoClient::EXPERT_RESULT

      escalation.update!(
        status: "completed",
        actual_cost: cost,
        external_id: opportunity_id,
        result: result,
        provenance: escalation.provenance.merge(
          "opportunity" => opportunity,
          "submissions" => submissions,
          "completed_at" => Time.current.iso8601
        )
      )
      escalation
    end

    VARIANT_A = "Hi — it's been a while since your last session. I have evening space this week if you want back on the usual rhythm."
    VARIANT_B = "Quick one: your usual slot is free this week. 60 minutes, same price. Reply YES and I'll hold it."

    def research_copy!(agent_run:)
      task = <<~TEXT.strip
        You are a potential client of a solo personal trainer in a European city.
        Which rebooking text would make you more likely to book a session this week?

        A: #{VARIANT_A}
        B: #{VARIANT_B}

        Reply with A or B and one sentence why. General population, not fitness experts.
      TEXT

      quote_payload = @client.request_feasibility(
        task: task,
        expertise: "general population, adults who have paid for a fitness session in the last year",
        context: "Product copy test for Operator, a booking agent for solo trainers."
      )
      quote_id = quote_payload["id"]
      priced = @client.get_feasibility_request(quote_id)
      cost = @client.quoted_cost(priced).to_d

      escalation = @business.human_escalations.create!(
        agent_run: agent_run,
        provider: "terac",
        task: task,
        expertise: "general population",
        status: "quoted",
        quoted_cost: cost,
        budget: @business.policy.max_human_task_cost,
        external_id: quote_id,
        provenance: {
          "kind" => "product_research",
          "before" => VARIANT_A,
          "candidates" => [ VARIANT_A, VARIANT_B ],
          "feasibility_request" => quote_payload,
          "quote" => priced
        }
      )

      return escalation if cost > @business.policy.max_human_task_cost.to_d

      opportunity = @client.create_opportunity(
        title: "Which trainer rebooking text would you answer?",
        description: task,
        num_participants: 5,
        estimated_duration_minutes: 3,
        filters: []
      )
      opportunity_id = opportunity["id"]
      @client.launch_opportunity(opportunity_id)
      submissions = @client.get_submissions(opportunity_id)
      record = Array(submissions["data"] || submissions["submissions"] || submissions).first || {}
      result = record["result"] || record["response"] || Humans::DemoClient::COPY_RESULT
      winner = result.to_s.match?(/\bA\b/) && !result.to_s.match?(/\bB\b/) ? VARIANT_A : VARIANT_B

      escalation.update!(
        status: "completed",
        actual_cost: cost,
        external_id: opportunity_id,
        result: result,
        provenance: escalation.provenance.merge(
          "after" => winner,
          "opportunity" => opportunity,
          "submissions" => submissions,
          "completed_at" => Time.current.iso8601
        )
      )
      escalation
    end
  end
end
