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
        filters: [ { "multi_select--job_function" => { "$in" => [ "physiotherapist", "personal-trainer" ] } } ]
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
  end
end
