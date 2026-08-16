module Agent
  class Planner
    def initialize(business)
      @business = business
      @calendar = Tools::CalendarTool.new(business)
      @messaging = Tools::MessagingTool.new(business)
    end

    def decide(snapshot)
      done = snapshot[:done]

      return business_check(snapshot) unless done.include?("business_check")

      cancelled = snapshot[:appointments][:cancelled].first
      if cancelled
        decision = cancellation_flow(cancelled, done)
        return decision if decision
      end

      unpaid = snapshot[:unpaid_payments].first
      return payment_reminder(unpaid) if unpaid && !done.include?("payment_reminder")

      inactive = snapshot[:customers_needing_attention][:inactive].first
      if inactive && !done.include?("rebooking")
        return copy_research unless done.include?("copy_research")
        return rebooking(inactive)
      end

      lead = snapshot[:new_leads].first
      return lead_follow_up(lead) if lead && !done.include?("lead_follow_up")

      review = snapshot[:customers_needing_attention][:reviews].first
      return review_request(snapshot[:customers_needing_attention][:reviews]) if review && !done.include?("review_request")

      human = snapshot[:customers_needing_attention][:human].first
      if human && !done.include?("human_help")
        return human_help(human)
      end

      applied = done.include?("apply_human_result")
      escalation = expert_escalation
      return apply_human_result(human_from(escalation), escalation) if escalation && !applied && human_from(escalation)

      { type: "stop", description: "No useful work remains.", confidence: 100, cost: 0 }
    end

    private

    def business_check(snapshot)
      active = @business.customers.active.count
      inactive = @business.customers.inactive.count
      unpaid = snapshot[:unpaid_payments].size
      cancelled = snapshot[:appointments][:cancelled].size
      slots = snapshot[:appointments][:open_slots].size
      leads = snapshot[:new_leads].size

      {
        type: "business_check",
        description: [
          "BUSINESS CHECK",
          "",
          "#{active} active clients",
          "#{inactive} inactive clients",
          "#{unpaid} unpaid #{'invoice'.pluralize(unpaid)}",
          "#{cancelled} cancellation today",
          "#{slots} open calendar slots",
          "#{leads} unanswered #{'lead'.pluralize(leads)}"
        ].join("\n"),
        confidence: 100,
        cost: 0
      }
    end

    def cancellation_flow(cancelled, done)
      candidates = @calendar.replacement_candidates(cancelled)
      return unless candidates.any?

      if !done.include?("contact_replacement")
        pick = candidates.first
        {
          type: "contact_replacement",
          customer: pick.customer,
          appointment: cancelled,
          candidates: candidates,
          description: [
            "#{cancelled.starts_at.strftime("%H:%M")} cancellation detected.",
            "",
            "Found #{candidates.size} candidates likely to accept this slot.",
            "",
            "I picked #{pick.customer.name.split.first} because she #{pick.why}."
          ].join("\n"),
          confidence: 88,
          cost: 0
        }
      elsif !done.include?("book_replacement")
        contacted = @business.customers.find_by(demo_behavior: "accept") || candidates.first.customer
        reply = @messaging.unanswered_accept_for(contacted)
        if reply
          {
            type: "book_replacement",
            customer: contacted,
            appointment: cancelled,
            message: reply,
            description: "#{contacted.name.split.first} accepted.\n\nBooking the #{cancelled.starts_at.strftime("%H:%M")} slot now.",
            confidence: 95,
            cost: 0
          }
        end
      end
    end

    def payment_reminder(payment)
      days = ((Time.current - payment.due_at) / 1.day).ceil
      {
        type: "payment_reminder",
        customer: payment.customer,
        payment: payment,
        description: "#{payment.customer.name.split.first} has an unpaid #{MoneyDisplay.call(payment.amount, payment.currency)} invoice (#{days} days late).\n\nSending a payment reminder.",
        confidence: 90,
        cost: 0
      }
    end

    def copy_research
      {
        type: "copy_research",
        description: [
          "Before sending Kasia a rebooking text, test two versions with real people.",
          "",
          "Launching a Terac General Population study (not specialists).",
          "The winning copy is what we send."
        ].join("\n"),
        confidence: 84,
        cost: 0
      }
    end

    def rebooking(customer)
      {
        type: "rebooking",
        customer: customer,
        description: "#{customer.name.split.first} normally books every #{customer.usual_interval_days} days.\nLast session: #{customer.days_since_visit} days ago.\n\nSending a rebooking message.",
        confidence: 82,
        cost: 0
      }
    end

    def lead_follow_up(lead)
      {
        type: "lead_follow_up",
        customer: lead.customer,
        lead: lead,
        description: "Unanswered lead: #{lead.customer&.name || "someone"} asked about #{lead.intent}. Never booked.\n\nFollowing up.",
        confidence: 80,
        cost: 0
      }
    end

    def review_request(customers)
      names = customers.map { |c| c.name.split.first }.to_sentence
      {
        type: "review_request",
        customers: customers.to_a,
        customer: customers.first,
        description: "#{customers.size} recent clients completed their first package (#{names}).\n\nRequesting reviews.",
        confidence: 85,
        cost: 0
      }
    end

    def human_help(customer)
      {
        type: "human_help",
        customer: customer,
        cost: 18,
        budget: @business.policy.max_human_task_cost,
        description: [
          "#{customer.name.split.first} asked whether their training program should be modified after an injury.",
          "",
          "I am not confident enough to answer. This needs a real human.",
          "",
          "Finding an appropriate expert via Terac. Budget: #{MoneyDisplay.call(@business.policy.max_human_task_cost, "usd")}."
        ].join("\n"),
        confidence: 62,
        expertise: "sports physiotherapist, Warsaw, injury modification for personal training clients"
      }
    end

    def apply_human_result(customer, escalation)
      {
        type: "apply_human_result",
        customer: customer,
        escalation: escalation,
        description: "Human result received from Terac.\n\nPassing the physiotherapist's guidance to #{customer.name.split.first}.",
        confidence: 94,
        cost: 0
      }
    end

    def human_from(escalation)
      return unless escalation
      @business.customers.where.not(open_question: [ nil, "" ]).first ||
        @business.customers.find_by(demo_behavior: "escalate")
    end

    def expert_escalation
      @business.human_escalations.where(status: "completed").order(:id).to_a.reverse.find do |escalation|
        escalation.provenance.to_h["kind"] != "product_research"
      end
    end
  end
end
