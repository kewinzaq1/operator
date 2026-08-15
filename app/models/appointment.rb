class Appointment < ApplicationRecord
  belongs_to :business
  belongs_to :customer
  belongs_to :service
  has_many :payments, dependent: :nullify
  belongs_to :recovered_by_appointment, class_name: "Appointment", optional: true

  validates :starts_at, :ends_at, :status, presence: true

  scope :today, -> { where(starts_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :scheduled, -> { where(status: "scheduled") }
  scope :completed, -> { where(status: "completed") }
  scope :unrecovered, -> { cancelled.where(recovered_by_appointment_id: nil) }

  def cancelled?
    status == "cancelled"
  end

  def recovered?
    recovered_by_appointment_id.present?
  end
end
