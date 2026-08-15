require "test_helper"

class HumanToolTest < ActiveSupport::TestCase
  test "quotes via Terac adapter then records provenance and cost" do
    business = seed_demo!
    run = business.agent_runs.create!(status: "running", trigger: "test")
    wojtek = business.customers.find_by(name: "Wojtek Pawlak")

    escalation = Tools::HumanTool.new(business).request_help!(
      agent_run: run,
      task: wojtek.open_question,
      expertise: "sports physiotherapist",
      budget: 20,
      context: wojtek.notes
    )

    assert_equal "completed", escalation.status
    assert_equal "terac", escalation.provider
    assert_equal 18, escalation.quoted_cost
    assert escalation.provenance["quote"].present?
    assert_match(/physiotherapist|mobility|isometric/i, escalation.result)
  end
end
