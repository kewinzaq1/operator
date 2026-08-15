module Tools
  class CustomerTool
    def initialize(business)
      @business = business
    end

    def inactive
      @business.customers.select(&:overdue_for_rebooking?).sort_by { |c| c.days_since_visit || 999 }
    end

    def unanswered_leads
      @business.leads.unanswered.includes(:customer)
    end

    def review_candidates
      @business.customers.needing_review
    end

    def needing_human
      @business.customers.where.not(open_question: [ nil, "" ])
    end

    def mark_followed_up!(lead)
      lead.update!(status: "followed_up", last_message_at: Time.current)
    end

    def mark_review_requested!(customer)
      customer.update!(review_requested_at: Time.current)
    end

    def clear_question!(customer)
      customer.update!(open_question: nil)
    end
  end
end
