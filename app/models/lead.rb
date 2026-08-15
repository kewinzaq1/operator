class Lead < ApplicationRecord
  belongs_to :business
  belongs_to :customer, optional: true

  scope :unanswered, -> { where(status: %w[new unanswered]) }
end
