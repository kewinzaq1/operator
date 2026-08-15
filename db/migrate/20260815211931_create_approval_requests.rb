class CreateApprovalRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :approval_requests do |t|
      t.references :business, null: false, foreign_key: true
      t.references :agent_run, foreign_key: true
      t.string :request_type, null: false
      t.text :description
      t.decimal :amount, precision: 10, scale: 2
      t.string :status, default: "pending", null: false
      t.jsonb :payload, default: {}, null: false
      t.datetime :decided_at

      t.timestamps
    end
  end
end
