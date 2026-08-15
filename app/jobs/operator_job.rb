class OperatorJob < ApplicationJob
  queue_as :default

  def perform(agent_run_id)
    run = AgentRun.find(agent_run_id)
    Agent::Operator.new(run).run
  end
end
