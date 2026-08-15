class InstallSolidInfrastructure < ActiveRecord::Migration[8.1]
  def up
    load Rails.root.join("db/queue_schema.rb") unless table_exists?(:solid_queue_jobs)
    load Rails.root.join("db/cache_schema.rb") unless table_exists?(:solid_cache_entries)
    load Rails.root.join("db/cable_schema.rb") unless table_exists?(:solid_cable_messages)
  end

  def down
    drop_table :solid_queue_blocked_executions, if_exists: true
    drop_table :solid_queue_claimed_executions, if_exists: true
    drop_table :solid_queue_failed_executions, if_exists: true
    drop_table :solid_queue_ready_executions, if_exists: true
    drop_table :solid_queue_recurring_executions, if_exists: true
    drop_table :solid_queue_scheduled_executions, if_exists: true
    drop_table :solid_queue_recurring_tasks, if_exists: true
    drop_table :solid_queue_pauses, if_exists: true
    drop_table :solid_queue_processes, if_exists: true
    drop_table :solid_queue_semaphores, if_exists: true
    drop_table :solid_queue_jobs, if_exists: true
    drop_table :solid_cache_entries, if_exists: true
    drop_table :solid_cable_messages, if_exists: true
  end
end
