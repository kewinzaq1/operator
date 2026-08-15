class CreateAgentActions < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_actions do |t|
      t.references :agent_run, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.references :customer, foreign_key: true
      t.references :appointment, foreign_key: true
      t.string :action_type, null: false
      t.text :description
      t.string :status, default: "pending", null: false
      t.decimal :cost, precision: 10, scale: 2, default: 0
      t.integer :confidence
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end
  end
end
