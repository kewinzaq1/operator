module Payments
  # Hackathon guidebook: one Stripe Payment Link for every transaction.
  # Organizers track revenue on the team's personal Stripe account.
  class PaymentLinkClient < Provider
    def create_checkout_session(payment:, success_url:, cancel_url:)
      url = ENV.fetch("STRIPE_PAYMENT_LINK_URL")
      Session.new(
        id: "plink_#{payment.id}",
        url: url,
        status: "open",
        raw: { "provider" => "stripe_payment_link", "success_url" => success_url, "cancel_url" => cancel_url }
      )
    end

    def refund(payment:, amount:)
      raise "Refunds are not available on the shared hackathon Payment Link"
    end
  end
end
