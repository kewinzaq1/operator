class ApplicationController < ActionController::Base
  helper_method :current_business, :demo_mode?

  private

  def current_business
    @current_business ||= Business.includes(:policy, :customers, :appointments).first
  end

  def demo_mode?
    Rails.application.config.demo_mode
  end

  def require_business
    return if current_business
    redirect_to root_path, alert: "Seed the demo business first."
  end
end
