class AgentRunsController < ApplicationController
  before_action :require_business

  def create
    @business = current_business
    if Agents::RenderWorkflow.enabled? && ENV["OPERATOR_JOB_TOKEN"].present?
      start_local_run unless start_via_render_workflow
    else
      start_local_run
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_path, notice: @workflow_notice }
    end
  end

  private

  def start_local_run
    @run = @business.agent_runs.create!(
      status: "pending",
      trigger: "run_my_business",
      started_at: Time.current,
      environment: Providers.sandbox.environment_name,
      sandbox_status: "RUNNING",
      sandbox_task: "daily business review"
    )
    OperatorJob.perform_later(@run.id)
  end

  def start_via_render_workflow
    Agents::RenderWorkflow.new.start!(
      app_url: operator_app_url,
      token: ENV.fetch("OPERATOR_JOB_TOKEN")
    )
    @workflow_notice = "Operator queued on Render Workflow."
    true
  rescue => e
    Rails.logger.error("[RenderWorkflow] #{e.class}: #{e.message}")
    @workflow_notice = "Render Workflow failed; running locally."
    false
  end

  def operator_app_url
    host = ENV["APP_HOST"].presence
    return request.base_url if host.blank?
    return host if host.start_with?("http://", "https://")

    "#{host.include?("localhost") ? "http" : "https"}://#{host}"
  end
end
