class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.integer :duration_minutes
      t.decimal :price
      t.text :description

      t.timestamps
    end
  end
end
