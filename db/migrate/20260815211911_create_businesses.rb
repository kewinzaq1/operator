class CreateBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :business_type
      t.string :currency
      t.string :timezone
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
