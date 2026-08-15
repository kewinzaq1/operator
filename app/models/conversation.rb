class Conversation < ApplicationRecord
  belongs_to :business
  belongs_to :customer
  has_many :messages, dependent: :destroy

  def last_message
    messages.order(:sent_at, :id).last
  end
end
