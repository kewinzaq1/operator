require "test_helper"

class PaymentsToolTest < ActiveSupport::TestCase
  test "payment reminder is allowed by policy and marks overdue invoices" do
    business = seed_demo!
    run = business.agent_runs.create!(status: "running", trigger: "test")
    payment = business.payments.unpaid.first
    decision = { type: "payment_reminder", cost: 0, payment: payment, customer: payment.customer, description: "remind" }

    assert Agent::Policy.new(business, run).check(decision).allowed?

    Tools::PaymentsTool.new(business).remind!(payment)
    assert_includes %w[overdue sent pending], payment.reload.status
  end
end
