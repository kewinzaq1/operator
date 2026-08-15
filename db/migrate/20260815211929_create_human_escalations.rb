class CreateHumanEscalations < ActiveRecord::Migration[8.1]
  def change
    create_table :human_escalations do |t|
      t.references :business, null: false, foreign_key: true
      t.references :agent_run, null: false, foreign_key: true
      t.string :provider
      t.text :task
      t.string :expertise
      t.string :status, default: "quoting"
      t.decimal :quoted_cost, precision: 10, scale: 2
      t.decimal :actual_cost, precision: 10, scale: 2
      t.decimal :budget, precision: 10, scale: 2
      t.string :external_id
      t.text :result
      t.jsonb :provenance, default: {}, null: false
      t.datetime :deadline

      t.timestamps
    end
  end
end
