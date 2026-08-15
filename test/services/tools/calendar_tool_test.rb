require "test_helper"

class CalendarToolTest < ActiveSupport::TestCase
  test "ranks Marta first for a 17:00 cancellation" do
    business = seed_demo!
    cancelled = business.appointments.unrecovered.find_by(status: "cancelled")
    candidates = Tools::CalendarTool.new(business).replacement_candidates(cancelled)
    assert_operator candidates.size, :>=, 3
    assert_equal "Marta Kowalska", candidates.first.customer.name
  end
end
