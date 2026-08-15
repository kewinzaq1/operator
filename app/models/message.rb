class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :agent_action, optional: true

  scope :inbound, -> { where(direction: "inbound") }
  scope :outbound, -> { where(direction: "outbound") }
  scope :recent, -> { order(sent_at: :desc) }

  def inbound?
    direction == "inbound"
  end
end
