module Webhooks
  class StripeController < ApplicationController
    skip_forgery_protection

    def create
      payload = request.body.read
      secret = ENV["STRIPE_WEBHOOK_SECRET"]

      event = if secret.present?
        Stripe::Webhook.construct_event(payload, request.env["HTTP_STRIPE_SIGNATURE"], secret)
      else
        JSON.parse(payload)
      end

      type = event.is_a?(Hash) ? event["type"] : event.type
      object = event.is_a?(Hash) ? event.dig("data", "object") : event.data.object

      if type.to_s.in?(%w[checkout.session.completed payment_intent.succeeded])
        payment = Payment.find_by(external_id: object["id"] || object.id) ||
          Payment.find_by(id: object["client_reference_id"] || object.try(:client_reference_id))
        Payments::WebhookHandler.mark_paid!(payment, external_id: object["id"] || object.id) if payment
      end

      head :ok
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
    end
  end
end
