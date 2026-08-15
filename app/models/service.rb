class Service < ApplicationRecord
  belongs_to :business
  has_many :appointments, dependent: :restrict_with_error

  validates :name, :duration_minutes, :price, presence: true
end
