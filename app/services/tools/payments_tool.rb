module Tools
  class PaymentsTool
    def initialize(business, provider: Providers.payments)
      @business = business
      @provider = provider
    end

    def create_checkout!(appointment:, success_url:, cancel_url:)
      payment = @business.payments.create!(
        customer: appointment.customer,
        appointment: appointment,
        provider: provider_name,
        amount: appointment.price,
        currency: @business.currency,
        status: "pending",
        due_at: Time.current
      )

      session = @provider.create_checkout_session(
        payment: payment,
        success_url: success_url,
        cancel_url: cancel_url
      )

      payment.update!(external_id: session.id, checkout_url: session.url, status: "sent")
      appointment.update!(payment_status: "sent")
      payment
    end

    def remind!(payment)
      payment.update!(status: "overdue") if payment.due_at && payment.due_at < Time.current && payment.status == "pending"
      payment
    end

    def refund!(payment, amount)
      @provider.refund(payment: payment, amount: amount)
      payment.update!(status: "refunded")
    end

    def overdue
      @business.payments.overdue.or(@business.payments.unpaid.where("due_at < ?", Time.current))
    end

    private

    def provider_name
      @provider.is_a?(Payments::StripeClient) ? "stripe" : "stripe"
    end
  end
end
