class DashboardController < ApplicationController
  before_action :require_business

  def show
    @business = current_business
    @run = @business.agent_runs.newest.first
    @today_appointments = @business.appointments.today.order(:starts_at)
    @unpaid = @business.payments.unpaid.order(:due_at)
    @attention = Tools::CustomerTool.new(@business)
    @escalations = @business.human_escalations.newest.limit(5)
    @approvals = @business.approval_requests.pending
    @automations = AgentAction.where(business: @business, status: "completed").where.not(action_type: %w[business_check impact]).order(created_at: :desc).limit(8)
    @week_revenue = @business.payments.paid.where(paid_at: 7.days.ago..).sum(:amount)
    @recovered = @business.business_metrics.of_type("recovered_revenue").where(occurred_at: 7.days.ago..).sum(:value)
    @bookings = @business.appointments.where(starts_at: Time.zone.now.all_day).where.not(status: "cancelled").count
    @minutes = @business.agent_runs.where(created_at: 7.days.ago..).sum(:minutes_saved)
    @issues = @business.agent_runs.where(created_at: 7.days.ago..).sum(:messages_sent)
  end
end
