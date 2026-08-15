module Agent
  class Memory
    def initialize(business, run)
      @business = business
      @run = run
    end

    def snapshot
      calendar = Tools::CalendarTool.new(@business)
      customers = Tools::CustomerTool.new(@business)
      today = Time.zone.today
      cancelled = @business.appointments.unrecovered.where(starts_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
      {
        business: @business,
        policy: @business.policy,
        today: today,
        appointments: {
          today: @business.appointments.today.order(:starts_at),
          cancelled: cancelled,
          open_slots: calendar.open_slots(today)
        },
        customers_needing_attention: {
          inactive: customers.inactive,
          reviews: customers.review_candidates,
          human: customers.needing_human
        },
        unpaid_payments: @business.payments.unpaid.select(&:overdue?),
        new_leads: customers.unanswered_leads,
        recent_messages: Message.joins(:conversation).where(conversations: { business_id: @business.id }).order(sent_at: :desc).limit(20),
        done: @run.agent_actions.pluck(:action_type),
        actions: @run.agent_actions
      }
    end
  end
end
