class AgentAction < ApplicationRecord
  belongs_to :agent_run
  belongs_to :business
  belongs_to :customer, optional: true
  belongs_to :appointment, optional: true
  has_many :messages, dependent: :nullify

  after_create_commit :broadcast_create, unless: -> { Rails.env.test? }
  after_update_commit :broadcast_update, unless: -> { Rails.env.test? }

  scope :chronological, -> { order(:created_at, :id) }

  def completed?
    status == "completed"
  end

  def blocked?
    status == "blocked"
  end

  private

  def broadcast_create
    broadcast_append_to agent_run.stream_name, target: "operator-feed", partial: "dashboard/action", locals: { action: self }
  end

  def broadcast_update
    broadcast_replace_to agent_run.stream_name, target: ActionView::RecordIdentifier.dom_id(self), partial: "dashboard/action", locals: { action: self }
  end
end
