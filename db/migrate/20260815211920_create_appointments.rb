class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :status, default: "scheduled"
      t.decimal :price, precision: 10, scale: 2
      t.string :payment_status, default: "unpaid"
      t.datetime :cancelled_at
      t.string :cancellation_reason
      t.integer :recovered_by_appointment_id
      t.index :starts_at

      t.timestamps
    end
  end
end
