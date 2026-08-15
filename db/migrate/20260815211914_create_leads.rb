class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :business, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :source
      t.string :status
      t.datetime :last_message_at
      t.string :intent
      t.text :body

      t.timestamps
    end
  end
end
