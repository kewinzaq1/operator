class CreateBusinessMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :business_metrics do |t|
      t.references :business, null: false, foreign_key: true
      t.string :metric_type
      t.decimal :value
      t.datetime :occurred_at
      t.jsonb :metadata, default: {}, null: false
      t.index [ :business_id, :metric_type, :occurred_at ]

      t.timestamps
    end
  end
end
