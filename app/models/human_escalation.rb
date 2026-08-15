class HumanEscalation < ApplicationRecord
  belongs_to :business
  belongs_to :agent_run, optional: true

  scope :newest, -> { order(created_at: :desc) }

  def completed?
    status == "completed"
  end

  def quoted?
    quoted_cost.present?
  end
end
