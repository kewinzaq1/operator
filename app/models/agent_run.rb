class AgentRun < ApplicationRecord
  belongs_to :business
  has_many :agent_actions, dependent: :destroy
  has_many :human_escalations, dependent: :destroy
  has_many :approval_requests, dependent: :nullify

  after_update_commit :broadcast_run_state, unless: -> { Rails.env.test? }

  scope :newest, -> { order(created_at: :desc) }

  def running?
    status == "running"
  end

  def completed?
    status == "completed"
  end

  def stream_name
    "agent_run_#{id}"
  end

  def action_types
    agent_actions.pluck(:action_type)
  end

  private

  def broadcast_run_state
    broadcast_replace_to stream_name, target: "run-status", partial: "dashboard/run_status", locals: { run: self }
    broadcast_replace_to stream_name, target: "today-impact", partial: "dashboard/impact", locals: { run: self }
    broadcast_replace_to stream_name, target: "metrics-strip", partial: "dashboard/metrics", locals: { business: business, run: self }
  end
end
