module Payments
  # Stripe Checkout Sessions are the source of payment links.
  # Webhooks (checkout.session.completed, payment_intent.succeeded) are the source of truth.
  class StripeClient < Provider
    def initialize(api_key: ENV["STRIPE_SECRET_KEY"])
      Stripe.api_key = api_key
    end

    def create_checkout_session(payment:, success_url:, cancel_url:)
      session = Stripe::Checkout::Session.create(
        mode: "payment",
        success_url: success_url,
        cancel_url: cancel_url,
        customer_email: payment.customer.email.presence,
        client_reference_id: payment.id.to_s,
        metadata: {
          payment_id: payment.id,
          business_id: payment.business_id,
          appointment_id: payment.appointment_id
        },
        line_items: [ {
          quantity: 1,
          price_data: {
            currency: payment.currency.downcase,
            unit_amount: (payment.amount.to_d * 100).to_i,
            product_data: {
              name: payment.appointment&.service&.name || "Session"
            }
          }
        } ]
      )

      Session.new(id: session.id, url: session.url, status: session.status, raw: session.to_hash)
    end

    def refund(payment:, amount:)
      Stripe::Refund.create(
        payment_intent: payment.external_id,
        amount: (amount.to_d * 100).to_i
      )
    end
  end
end
