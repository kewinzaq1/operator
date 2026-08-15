class CreateDigitalProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :digital_products do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.string :kind
      t.decimal :price
      t.string :provider
      t.string :external_id
      t.text :description

      t.timestamps
    end
  end
end
