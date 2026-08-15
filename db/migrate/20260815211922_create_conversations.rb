class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :channel
      t.string :status
      t.string :external_id

      t.timestamps
    end
  end
end
