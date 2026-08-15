class AgentRunsController < ApplicationController
  before_action :require_business

  def create
    @business = current_business
    @run = @business.agent_runs.create!(
      status: "pending",
      trigger: "run_my_business",
      started_at: Time.current,
      environment: Providers.sandbox.environment_name,
      sandbox_status: "RUNNING",
      sandbox_task: "daily business review"
    )
    OperatorJob.perform_later(@run.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_path }
    end
  end
end
