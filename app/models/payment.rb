class Payment < ApplicationRecord
  belongs_to :business
  belongs_to :customer
  belongs_to :appointment, optional: true

  validates :amount, :currency, :status, :provider, presence: true

  scope :unpaid, -> { where(status: %w[pending sent overdue]) }
  scope :overdue, -> { unpaid.where("due_at < ?", Time.current) }
  scope :paid, -> { where(status: "paid") }

  def overdue?
    unpaid? && due_at.present? && due_at < Time.current
  end

  def unpaid?
    %w[pending sent overdue].include?(status)
  end
end
