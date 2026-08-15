module Payments
  class DemoClient < Provider
    def create_checkout_session(payment:, success_url:, cancel_url:)
      id = "cs_demo_#{SecureRandom.hex(8)}"
      Session.new(
        id: id,
        url: "#{success_url}?demo_session=#{id}&payment_id=#{payment.id}",
        status: "open",
        raw: { "demo" => true, "success_url" => success_url, "cancel_url" => cancel_url }
      )
    end

    def refund(payment:, amount:)
      { "id" => "re_demo_#{SecureRandom.hex(6)}", "amount" => amount, "status" => "succeeded" }
    end
  end
end
