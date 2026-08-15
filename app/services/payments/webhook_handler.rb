module Payments
  class WebhookHandler
    def self.mark_paid!(payment, external_id: nil)
      payment.update!(
        status: "paid",
        paid_at: Time.current,
        external_id: external_id.presence || payment.external_id
      )
      payment.appointment&.update!(payment_status: "paid")
      BusinessMetric.create!(
        business: payment.business,
        metric_type: "payment_collected",
        value: payment.amount,
        occurred_at: Time.current,
        metadata: { payment_id: payment.id, provider: payment.provider }
      )
      payment
    end
  end
end
