class BusinessPolicy < ApplicationRecord
  belongs_to :business

  validates :session_price, :max_auto_refund, :max_agent_spend, :max_human_task_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :cancellation_window_hours, :late_payment_days, :confidence_threshold, numericality: { greater_than_or_equal_to: 0 }

  def working_hours_for(date)
    key = date.strftime("%A").downcase
    hours = working_hours.is_a?(Hash) ? working_hours : {}
    hours[key] || hours[key.to_s]
  end

  def open_on?(date)
    slots = working_hours_for(date)
    slots.present?
  end
end
