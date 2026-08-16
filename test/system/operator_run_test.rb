require "application_system_test_case"

class OperatorRunTest < ApplicationSystemTestCase
  driven_by :rack_test

  setup { seed_demo! }

  test "run my business recovers the 17:00 cancellation end to end" do
    visit dashboard_path
    assert_text "Anna Fitness"
    assert_text "cancelled"
    assert_text "Filip Mazur"

    click_button "Run my business"

    assert_text "BUSINESS CHECK"
    assert_text "cancellation detected"
    assert_text "Marta"
    assert_text "Yep, 17:00 works for me"
    assert_text "ACCEPT"
    assert_text "Payment request sent"
    assert_text "unpaid"
    assert_text "general population"
    assert_text "rebooking"
    assert_text "Terac"
    assert_text "TODAY'S IMPACT"
    assert_text "You have nothing urgent to do"
  end
end
