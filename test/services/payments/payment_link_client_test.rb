require "test_helper"

class PaymentLinkClientTest < ActiveSupport::TestCase
  setup do
    @previous_link = ENV["STRIPE_PAYMENT_LINK_URL"]
  end

  teardown do
    if @previous_link
      ENV["STRIPE_PAYMENT_LINK_URL"] = @previous_link
    else
      ENV.delete("STRIPE_PAYMENT_LINK_URL")
    end
  end

  test "every checkout uses the same Stripe Payment Link" do
    business = seed_demo!
    payment = business.payments.unpaid.first
    url = "https://buy.stripe.com/test_operator_hackathon"
    ENV["STRIPE_PAYMENT_LINK_URL"] = url

    session = Payments::PaymentLinkClient.new.create_checkout_session(
      payment: payment,
      success_url: "http://localhost/ok",
      cancel_url: "http://localhost/no"
    )

    assert_equal url, session.url
    assert_equal "open", session.status
  end

  test "Providers.payments prefers the payment link over demo" do
    ENV["STRIPE_PAYMENT_LINK_URL"] = "https://buy.stripe.com/test_operator_hackathon"
    assert_instance_of Payments::PaymentLinkClient, Providers.payments
  end
end
