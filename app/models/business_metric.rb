class BusinessMetric < ApplicationRecord
  belongs_to :business

  scope :recent, -> { order(occurred_at: :desc) }
  scope :of_type, ->(type) { where(metric_type: type) }
end
