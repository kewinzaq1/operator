class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.text :notes
      t.string :status
      t.datetime :last_contacted_at
      t.datetime :last_visit_at
      t.jsonb :preferred_days
      t.jsonb :preferred_times
      t.integer :usual_interval_days
      t.string :demo_behavior
      t.boolean :package_completed, default: false
      t.datetime :review_requested_at
      t.boolean :opted_out, default: false
      t.text :open_question

      t.timestamps
    end
  end
end
