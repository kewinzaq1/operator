require "test_helper"

class BusinessPolicyTest < ActiveSupport::TestCase
  setup do
    @business = Business.create!(name: "Studio", business_type: "personal_trainer", currency: "pln", timezone: "Europe/Warsaw")
  end

  test "rejects negative spend limits" do
    policy = @business.build_policy(session_price: 80, max_auto_refund: -1, max_agent_spend: 10, max_human_task_cost: 10, confidence_threshold: 70, late_payment_days: 3, cancellation_window_hours: 24)
    assert_not policy.valid?
  end

  test "belongs to a business and stores working hours" do
    policy = @business.create_policy!(
      session_price: 80,
      max_auto_refund: 100,
      max_agent_spend: 50,
      max_human_task_cost: 20,
      working_hours: { "monday" => { "start" => "07:00", "end" => "21:00" } }
    )
    assert policy.open_on?(Date.new(2026, 8, 17))
    assert_equal "07:00", policy.working_hours_for(Date.new(2026, 8, 17))["start"]
  end
end
