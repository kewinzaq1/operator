class Business < ApplicationRecord
  has_one :policy, class_name: "BusinessPolicy", dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :agent_runs, dependent: :destroy
  has_many :agent_actions, dependent: :destroy
  has_many :human_escalations, dependent: :destroy
  has_many :business_metrics, dependent: :destroy
  has_many :approval_requests, dependent: :destroy
  has_many :digital_products, dependent: :destroy

  validates :name, :timezone, :currency, presence: true

  def money(amount)
    MoneyDisplay.call(amount, currency)
  end
end
