class CreateBusinessPolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :business_policies do |t|
      t.references :business, null: false, foreign_key: true
      t.decimal :session_price, precision: 10, scale: 2
      t.string :currency, default: "pln"
      t.jsonb :working_hours, default: {}, null: false
      t.integer :cancellation_window_hours, default: 24
      t.decimal :cancellation_fee_percent, precision: 5, scale: 2, default: 50
      t.integer :late_payment_days, default: 3
      t.decimal :max_auto_refund, precision: 10, scale: 2, default: 100
      t.decimal :max_agent_spend, precision: 10, scale: 2, default: 50
      t.decimal :max_human_task_cost, precision: 10, scale: 2, default: 20
      t.string :communication_tone, default: "friendly"
      t.boolean :auto_booking_enabled, default: true
      t.boolean :auto_payment_enabled, default: true
      t.integer :confidence_threshold, default: 70

      t.timestamps
    end
  end
end
