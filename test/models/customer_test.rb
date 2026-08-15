require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "detects overdue rebooking from usual interval" do
    business = Business.create!(name: "Studio", business_type: "coach", currency: "pln", timezone: "Europe/Warsaw")
    customer = business.customers.create!(
      name: "Kasia",
      status: "inactive",
      usual_interval_days: 7,
      last_visit_at: 13.days.ago
    )
    assert customer.overdue_for_rebooking?
    assert_equal 13, customer.days_since_visit
  end
end
