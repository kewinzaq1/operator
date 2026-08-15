module Agent
  class Policy
    Result = Struct.new(:allowed?, :reason, :requires_owner_approval, keyword_init: true)

    def initialize(business, run)
      @business = business
      @policy = business.policy
      @run = run
    end

    def check(decision)
      cost = decision[:cost].to_d
      case decision[:type]
      when "refund"
        return deny("maximum autonomous refund is #{MoneyDisplay.call(@policy.max_auto_refund, @business.currency)}") if cost > @policy.max_auto_refund.to_d
      when "human_help", "hire_expert"
        if cost.positive? && cost > @policy.max_human_task_cost.to_d
          return deny("quoted human task cost exceeds max_human_task_cost (#{MoneyDisplay.call(@policy.max_human_task_cost, "usd")})")
        end
        return Result.new(allowed?: true, reason: nil, requires_owner_approval: false)
      when "book_replacement"
        return deny("auto-booking is disabled") unless @policy.auto_booking_enabled?
      when "create_payment", "payment_reminder"
        return deny("auto-payment is disabled") unless @policy.auto_payment_enabled?
      end

      if cost.positive? && (spent + cost) > @policy.max_agent_spend.to_d
        return deny("this would exceed max agent spend of #{MoneyDisplay.call(@policy.max_agent_spend, @business.currency)}")
      end

      Result.new(allowed?: true, reason: nil, requires_owner_approval: false)
    end

    def spent
      @run.agent_actions.where(status: "completed").sum(:cost).to_d
    end

    private

    def deny(reason)
      Result.new(allowed?: false, reason: reason, requires_owner_approval: true)
    end
  end
end
