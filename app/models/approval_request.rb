class ApprovalRequest < ApplicationRecord
  belongs_to :business
  belongs_to :agent_run, optional: true

  scope :pending, -> { where(status: "pending") }

  def pending?
    status == "pending"
  end

  def approve!
    update!(status: "approved", decided_at: Time.current)
  end

  def reject!
    update!(status: "rejected", decided_at: Time.current)
  end
end
