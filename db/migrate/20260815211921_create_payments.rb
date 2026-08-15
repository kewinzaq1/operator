class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :appointment, foreign_key: true
      t.string :provider, default: "stripe", null: false
      t.string :external_id
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "pln", null: false
      t.string :status, default: "pending", null: false
      t.datetime :due_at
      t.datetime :paid_at
      t.string :checkout_url

      t.timestamps
    end
  end
end
