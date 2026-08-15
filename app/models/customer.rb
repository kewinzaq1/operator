class Customer < ApplicationRecord
  belongs_to :business
  has_many :appointments, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :agent_actions, dependent: :nullify

  validates :name, presence: true

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :needing_review, -> { where(package_completed: true, review_requested_at: nil) }

  def preferred_days_list
    Array(preferred_days)
  end

  def preferred_times_list
    Array(preferred_times)
  end

  def days_since_visit
    return unless last_visit_at
    ((Time.current - last_visit_at) / 1.day).round
  end

  def overdue_for_rebooking?
    return false unless usual_interval_days.to_i.positive? && last_visit_at
    days_since_visit > usual_interval_days + 3
  end
end
