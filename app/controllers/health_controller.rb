class HealthController < ApplicationController
  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: "ok", demo: demo_mode? }, status: :ok
  rescue StandardError => e
    render json: { status: "error", error: e.message }, status: :service_unavailable
  end
end
