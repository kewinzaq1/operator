class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :direction, null: false
      t.text :body
      t.string :provider
      t.string :external_id
      t.string :status, default: "sent"
      t.datetime :sent_at
      t.string :intent
      t.bigint :agent_action_id

      t.timestamps
    end
  end
end
