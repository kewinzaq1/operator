module Internal
  class RunsController < ApplicationController
    skip_forgery_protection

    def create
      unless authentic_operator_token?
        head :unauthorized
        return
      end

      business = Business.first
      unless business
        render json: { ok: false, error: "no business" }, status: :unprocessable_entity
        return
      end

      run = business.agent_runs.create!(
        status: "pending",
        trigger: params[:trigger].presence || "render_workflow",
        started_at: Time.current,
        environment: Providers.sandbox.environment_name,
        sandbox_status: "RUNNING",
        sandbox_task: "daily business review"
      )
      OperatorJob.perform_later(run.id)
      render json: { ok: true, run_id: run.id }
    end

    private

    def authentic_operator_token?
      expected = ENV["OPERATOR_JOB_TOKEN"].to_s
      provided = request.headers["X-Operator-Token"].to_s
      return false if expected.blank? || provided.blank?

      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided),
        Digest::SHA256.hexdigest(expected)
      )
    end
  end
end
