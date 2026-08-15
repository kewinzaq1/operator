require "test_helper"

class AgentPolicyTest < ActiveSupport::TestCase
  setup do
    @business = seed_demo!
    @run = @business.agent_runs.create!(status: "running", trigger: "test")
    @policy = Agent::Policy.new(@business, @run)
  end

  test "blocks refunds above the autonomous limit" do
    result = @policy.check(type: "refund", cost: 180, description: "Refund 180")
    assert_not result.allowed?
    assert result.requires_owner_approval
    assert_match(/maximum autonomous refund/, result.reason)
  end

  test "blocks human tasks above max_human_task_cost" do
    @business.policy.update!(max_human_task_cost: 10)
    result = @policy.check(type: "human_help", cost: 23, description: "Hire expert")
    assert_not result.allowed?
    assert_match(/max_human_task_cost/, result.reason)
  end

  test "allows a terac job inside the budget" do
    result = @policy.check(type: "human_help", cost: 18, description: "Hire expert")
    assert result.allowed?
  end
end
