module Agent
  class Operator
    MAX_STEPS = 16

    def initialize(run)
      @run = run
      @business = run.business
      @memory = Memory.new(@business, @run)
      @planner = Planner.new(@business)
      @policy = Policy.new(@business, @run)
      @calendar = Tools::CalendarTool.new(@business)
      @messaging = Tools::MessagingTool.new(@business)
      @payments = Tools::PaymentsTool.new(@business)
      @customers = Tools::CustomerTool.new(@business)
      @humans = Tools::HumanTool.new(@business)
      @metrics = Tools::MetricsTool.new(@business)
      @band = Providers.band
      @sandbox = Providers.sandbox
    end

    def run
      info = @sandbox.start!(task: "daily business review")
      @run.update!(
        status: "running",
        started_at: Time.current,
        environment: info.environment,
        sandbox_status: info.status,
        sandbox_task: "daily business review"
      )
      @band.publish("Operator started daily run.")

      MAX_STEPS.times do
        snapshot = @memory.snapshot
        decision = @planner.decide(snapshot)
        break if decision.blank? || decision[:type] == "stop"

        action = record(decision, "running")
        verdict = @policy.check(decision)

        unless verdict.allowed?
          action.update!(status: "blocked", description: [ decision[:description], "", "BLOCKED — #{verdict.reason}", "Escalating to owner." ].join("\n"))
          create_approval(decision, verdict)
          @band.publish("Action blocked: #{verdict.reason}")
          pace
          next
        end

        result = execute(decision, action)
        finalize_action(action, decision, result)
        pace
      end

      wrap_up
    rescue => e
      @run.update!(status: "failed", finished_at: Time.current, summary: e.message)
      raise
    end

    private

    def record(decision, status)
      @run.agent_actions.create!(
        business: @business,
        customer: decision[:customer],
        appointment: decision[:appointment],
        action_type: decision[:type],
        description: decision[:description],
        status: status,
        cost: decision[:cost].to_d,
        confidence: decision[:confidence],
        metadata: { candidates: Array(decision[:candidates]).map { |c| { name: c.customer.name, why: c.why, score: c.score } } }
      )
    end

    def execute(decision, action)
      case decision[:type]
      when "business_check"
        { ok: true }
      when "contact_replacement"
        contact_replacement(decision, action)
      when "book_replacement"
        book_replacement(decision, action)
      when "payment_reminder"
        payment_reminder(decision, action)
      when "rebooking"
        rebooking(decision, action)
      when "lead_follow_up"
        lead_follow_up(decision, action)
      when "review_request"
        review_request(decision, action)
      when "human_help"
        human_help(decision, action)
      when "apply_human_result"
        apply_human_result(decision, action)
      else
        { ok: true }
      end
    end

    def contact_replacement(decision, action)
      @band.publish("Detected cancellation. Evaluating replacement candidates.")
      customer = decision[:customer]
      slot = decision[:appointment]
      first = customer.name.split.first
      body = "#{greeting}, #{first} — a #{slot.starts_at.strftime("%H:%M")} session just opened today. You usually like this time. Want it?"
      @messaging.send_message(customer: customer, body: body, agent_action: action)
      @run.increment!(:messages_sent)
      reply = @messaging.simulate_demo_reply(customer)
      extra = if reply
        "\n\n#{first.upcase}\n\n\"#{reply.body}\"\n\n→ Agent detected intent: #{reply.intent}"
      else
        "\n\nNo reply yet."
      end
      { ok: true, extra: extra, minutes: 8 }
    end

    def book_replacement(decision, action)
      cancelled = decision[:appointment]
      customer = decision[:customer]
      service = cancelled.service
      appointment = @calendar.book!(customer: customer, service: service, starts_at: cancelled.starts_at, source_appointment: cancelled)
      urls = checkout_urls
      payment = @payments.create_checkout!(appointment: appointment, success_url: urls[:success], cancel_url: urls[:cancel])
      @messaging.send_message(
        customer: customer,
        body: "#{greeting}, #{customer.name.split.first} — you're booked today at #{appointment.starts_at.strftime("%H:%M")}. Here's the payment link when you're ready: #{payment.checkout_url}",
        agent_action: action
      )
      @run.increment!(:messages_sent)
      @run.increment!(:recovered_revenue, appointment.price)
      @metrics.record!("recovered_revenue", appointment.price, { appointment_id: appointment.id })
      @band.publish("Slot booked. Payment request sent.")
      {
        ok: true,
        extra: "\n\nBooking created.\nPayment request sent.\n\n✓ #{MoneyDisplay.call(appointment.price, @business.currency)} recovered.",
        minutes: 12,
        appointment: appointment
      }
    end

    def payment_reminder(decision, action)
      payment = decision[:payment]
      customer = payment.customer
      urls = checkout_urls
      if payment.checkout_url.blank?
        session = Providers.payments.create_checkout_session(payment: payment, success_url: urls[:success], cancel_url: urls[:cancel])
        payment.update!(checkout_url: session.url, external_id: session.id, status: "sent")
      end
      @payments.remind!(payment)
      @messaging.send_message(
        customer: customer,
        body: "#{greeting}, #{customer.name.split.first} — quick reminder that #{MoneyDisplay.call(payment.amount, payment.currency)} is still open. Pay here when you can: #{payment.checkout_url}",
        agent_action: action
      )
      @run.increment!(:messages_sent)
      if Providers.demo_mode?
        Payments::WebhookHandler.mark_paid!(payment)
        @run.increment!(:recovered_unpaid, payment.amount)
      end
      @band.publish("Payment reminder sent.")
      { ok: true, extra: "\n\n✓ reminder sent", minutes: 5 }
    end

    def rebooking(decision, action)
      customer = decision[:customer]
      @messaging.send_message(
        customer: customer,
        body: "#{greeting}, #{customer.name.split.first} — it's been #{customer.days_since_visit} days since your last session. I have evening space this week if you want back on the usual rhythm.",
        agent_action: action
      )
      @run.increment!(:messages_sent)
      @run.increment!(:potential_booking, @business.policy.session_price)
      { ok: true, extra: "\n\n✓ rebooking message sent", minutes: 4 }
    end

    def lead_follow_up(decision, action)
      lead = decision[:lead]
      customer = lead.customer
      @messaging.send_message(
        customer: customer,
        body: "#{greeting} — you asked about #{lead.intent}. Sessions are #{MoneyDisplay.call(@business.policy.session_price, @business.currency)} and I still have Saturday morning space. Want me to hold a time?",
        agent_action: action
      )
      @customers.mark_followed_up!(lead)
      @run.increment!(:messages_sent)
      { ok: true, extra: "\n\n✓ lead followed up", minutes: 4 }
    end

    def review_request(decision, action)
      customers = decision[:customers] || [ decision[:customer] ]
      customers.each do |customer|
        @messaging.send_message(
          customer: customer,
          body: "#{greeting}, #{customer.name.split.first} — if last week's sessions felt good, a short Google review helps other people find the studio.",
          agent_action: action
        )
        @customers.mark_review_requested!(customer)
        @run.increment!(:messages_sent)
      end
      { ok: true, extra: "\n\n✓ review requests sent", minutes: 3 }
    end

    def human_help(decision, action)
      customer = decision[:customer]
      escalation = @humans.request_help!(
        agent_run: @run,
        task: customer.open_question.presence || "Advise whether a personal training program should be modified after a client injury.",
        expertise: decision[:expertise],
        budget: @business.policy.max_human_task_cost,
        context: "Client: #{customer.name}. Notes: #{customer.notes}"
      )
      action.update!(cost: escalation.quoted_cost)
      if escalation.status == "quoted" && escalation.quoted_cost.to_d > @business.policy.max_human_task_cost.to_d
        @business.approval_requests.create!(
          agent_run: @run,
          request_type: "hire_expert",
          description: "Hire expert for #{MoneyDisplay.call(escalation.quoted_cost, "usd")}?",
          amount: escalation.quoted_cost,
          payload: { escalation_id: escalation.id }
        )
        return { ok: false, extra: "\n\nQuoted cost exceeds policy. Waiting for owner approval." }
      end
      @band.publish("Escalating customer question to human.")
      {
        ok: true,
        extra: [
          "",
          "AI DECISION",
          "Confidence: #{decision[:confidence]}%",
          "Human review required.",
          "",
          "→ Terac",
          "→ matched expert: sports physiotherapist",
          "→ quoted cost: #{MoneyDisplay.call(escalation.quoted_cost, "usd")}",
          "→ completed",
          "→ result received"
        ].join("\n"),
        minutes: 6,
        escalation: escalation
      }
    end

    def apply_human_result(decision, action)
      customer = decision[:customer]
      escalation = decision[:escalation]
      @messaging.send_message(
        customer: customer,
        body: "#{greeting}, #{customer.name.split.first} — I had a sports physiotherapist look at this. #{escalation.result} If that feels right, I'll hold a lighter session for you this week.",
        agent_action: action
      )
      @customers.clear_question!(customer)
      @run.increment!(:messages_sent)
      { ok: true, extra: "\n\n✓ expert guidance sent to #{customer.name.split.first}", minutes: 4 }
    end

    def finalize_action(action, decision, result)
      extra = result[:extra]
      action.update!(
        status: result[:ok] == false ? "blocked" : "completed",
        description: [ decision[:description], extra ].compact.join("\n"),
        appointment: result[:appointment] || action.appointment,
        metadata: action.metadata.merge("result" => result.except(:appointment, :escalation).stringify_keys)
      )
      @run.increment!(:minutes_saved, result[:minutes].to_i)
    end

    def create_approval(decision, verdict)
      @business.approval_requests.create!(
        agent_run: @run,
        request_type: decision[:type],
        description: "#{decision[:description]}\n\n#{verdict.reason}",
        amount: decision[:cost],
        payload: { reason: verdict.reason }
      )
    end

    def wrap_up
      @sandbox.finish!
      summary = [
        "TODAY'S IMPACT",
        "",
        "Recovered revenue       #{MoneyDisplay.call(@run.recovered_revenue, @business.currency)}",
        "Recovered unpaid        #{MoneyDisplay.call(@run.recovered_unpaid, @business.currency)}",
        "Potential booking       #{MoneyDisplay.call(@run.potential_booking, @business.currency)}",
        "Messages sent              #{@run.messages_sent}",
        "Manual work avoided    ~#{@run.minutes_saved} min",
        "",
        "You have nothing urgent to do."
      ].join("\n")

      @run.agent_actions.create!(
        business: @business,
        action_type: "impact",
        description: summary,
        status: "completed",
        confidence: 100,
        metadata: {}
      )
      @run.update!(
        status: "completed",
        finished_at: Time.current,
        sandbox_status: "COMPLETED",
        summary: summary
      )
      @band.publish("Decision completed. Owner has nothing urgent to do.")
    end

    def greeting
      @business.policy.communication_tone.to_s == "formal" ? "Hello" : "Hi"
    end

    def checkout_urls
      host = ENV.fetch("APP_HOST", "localhost:3000")
      protocol = host.include?("localhost") ? "http" : "https"
      {
        success: "#{protocol}://#{host}/payments/success",
        cancel: "#{protocol}://#{host}/payments/cancel"
      }
    end

    def pace
      delay = Rails.application.config.operator_pace
      sleep(delay) if delay.positive?
    end
  end
end
