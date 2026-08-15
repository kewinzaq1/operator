class CreateAgentRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_runs do |t|
      t.references :business, null: false, foreign_key: true
      t.string :status, default: "pending"
      t.datetime :started_at
      t.datetime :finished_at
      t.string :trigger
      t.text :summary
      t.string :environment
      t.string :sandbox_status
      t.string :sandbox_task
      t.decimal :recovered_revenue, precision: 10, scale: 2, default: 0
      t.decimal :recovered_unpaid, precision: 10, scale: 2, default: 0
      t.decimal :potential_booking, precision: 10, scale: 2, default: 0
      t.integer :messages_sent, default: 0
      t.integer :minutes_saved, default: 0

      t.timestamps
    end
  end
end
