require "test_helper"

class OperatorTest < ActiveSupport::TestCase
  setup do
    @business = seed_demo!
  end

  test "recovers a cancellation, reminds, rebooks, and escalates to Terac" do
    run = @business.agent_runs.create!(status: "pending", trigger: "run_my_business")
    Agent::Operator.new(run).run
    run.reload

    assert_equal "completed", run.status
    types = run.agent_actions.pluck(:action_type)
    assert_includes types, "business_check"
    assert_includes types, "contact_replacement"
    assert_includes types, "book_replacement"
    assert_includes types, "payment_reminder"
    assert_includes types, "rebooking"
    assert_includes types, "human_help"
    assert_includes types, "apply_human_result"
    assert_includes types, "impact"

    marta = @business.customers.find_by(name: "Marta Kowalska")
    booked = @business.appointments.scheduled.find_by(customer: marta)
    assert booked
    assert_equal 17, booked.starts_at.hour
    assert booked.payments.where(status: "sent").exists?

    piotr_payment = @business.customers.find_by(name: "Piotr Nowak").payments.last
    assert_equal "paid", piotr_payment.status

    kasia = @business.customers.find_by(name: "Kasia Lewandowska")
    assert kasia.conversations.joins(:messages).exists?

    escalation = run.human_escalations.last
    assert_equal "completed", escalation.status
    assert_equal "terac", escalation.provider
    assert_operator escalation.quoted_cost, :<=, @business.policy.max_human_task_cost
    assert escalation.result.present?

    assert_equal 80, run.recovered_revenue
    assert_equal 70, run.recovered_unpaid
    assert_operator run.messages_sent, :>=, 4
  end

  test "agent trying to spend above the human task limit is blocked" do
    @business.policy.update!(max_human_task_cost: 5)
    run = @business.agent_runs.create!(status: "pending", trigger: "run_my_business")
    Agent::Operator.new(run).run

    blocked = run.agent_actions.find_by(action_type: "human_help")
    assert_equal "blocked", blocked.status
    assert @business.approval_requests.pending.exists?
    assert_not run.human_escalations.where(status: "completed").exists?
  end
end
