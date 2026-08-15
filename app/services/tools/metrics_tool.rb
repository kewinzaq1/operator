module Tools
  class MetricsTool
    def initialize(business)
      @business = business
    end

    def record!(type, value, metadata = {})
      @business.business_metrics.create!(
        metric_type: type,
        value: value,
        occurred_at: Time.current,
        metadata: metadata
      )
    end

    def revenue_today
      @business.payments.paid.where(paid_at: Time.zone.now.all_day).sum(:amount)
    end

    def unpaid_total
      @business.payments.unpaid.sum(:amount)
    end

    def recovered_today
      @business.business_metrics.of_type("recovered_revenue").where(occurred_at: Time.zone.now.all_day).sum(:value)
    end
  end
end
