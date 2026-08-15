# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_15_211940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agent_actions", force: :cascade do |t|
    t.string "action_type", null: false
    t.bigint "agent_run_id", null: false
    t.bigint "appointment_id"
    t.bigint "business_id", null: false
    t.integer "confidence"
    t.decimal "cost", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.text "description"
    t.jsonb "metadata", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_run_id"], name: "index_agent_actions_on_agent_run_id"
    t.index ["appointment_id"], name: "index_agent_actions_on_appointment_id"
    t.index ["business_id"], name: "index_agent_actions_on_business_id"
    t.index ["customer_id"], name: "index_agent_actions_on_customer_id"
  end

  create_table "agent_runs", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "environment"
    t.datetime "finished_at"
    t.integer "messages_sent", default: 0
    t.integer "minutes_saved", default: 0
    t.decimal "potential_booking", precision: 10, scale: 2, default: "0.0"
    t.decimal "recovered_revenue", precision: 10, scale: 2, default: "0.0"
    t.decimal "recovered_unpaid", precision: 10, scale: 2, default: "0.0"
    t.string "sandbox_status"
    t.string "sandbox_task"
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.text "summary"
    t.string "trigger"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_agent_runs_on_business_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "cancellation_reason"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "ends_at"
    t.string "payment_status", default: "unpaid"
    t.decimal "price", precision: 10, scale: 2
    t.integer "recovered_by_appointment_id"
    t.bigint "service_id", null: false
    t.datetime "starts_at"
    t.string "status", default: "scheduled"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_appointments_on_business_id"
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
    t.index ["starts_at"], name: "index_appointments_on_starts_at"
  end

  create_table "approval_requests", force: :cascade do |t|
    t.bigint "agent_run_id"
    t.decimal "amount", precision: 10, scale: 2
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.text "description"
    t.jsonb "payload", default: {}, null: false
    t.string "request_type", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_run_id"], name: "index_approval_requests_on_agent_run_id"
    t.index ["business_id"], name: "index_approval_requests_on_business_id"
  end

  create_table "business_metrics", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric_type"
    t.datetime "occurred_at"
    t.datetime "updated_at", null: false
    t.decimal "value"
    t.index ["business_id", "metric_type", "occurred_at"], name: "idx_on_business_id_metric_type_occurred_at_91187a4e29"
    t.index ["business_id"], name: "index_business_metrics_on_business_id"
  end

  create_table "business_policies", force: :cascade do |t|
    t.boolean "auto_booking_enabled", default: true
    t.boolean "auto_payment_enabled", default: true
    t.bigint "business_id", null: false
    t.decimal "cancellation_fee_percent", precision: 5, scale: 2, default: "50.0"
    t.integer "cancellation_window_hours", default: 24
    t.string "communication_tone", default: "friendly"
    t.integer "confidence_threshold", default: 70
    t.datetime "created_at", null: false
    t.string "currency", default: "pln"
    t.integer "late_payment_days", default: 3
    t.decimal "max_agent_spend", precision: 10, scale: 2, default: "50.0"
    t.decimal "max_auto_refund", precision: 10, scale: 2, default: "100.0"
    t.decimal "max_human_task_cost", precision: 10, scale: 2, default: "20.0"
    t.decimal "session_price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.jsonb "working_hours", default: {}, null: false
    t.index ["business_id"], name: "index_business_policies_on_business_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "business_type"
    t.datetime "created_at", null: false
    t.string "currency"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "timezone"
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "channel"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "external_id"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_conversations_on_business_id"
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.string "demo_behavior"
    t.string "email"
    t.datetime "last_contacted_at"
    t.datetime "last_visit_at"
    t.string "name"
    t.text "notes"
    t.text "open_question"
    t.boolean "opted_out", default: false
    t.boolean "package_completed", default: false
    t.string "phone"
    t.jsonb "preferred_days"
    t.jsonb "preferred_times"
    t.datetime "review_requested_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "usual_interval_days"
    t.index ["business_id"], name: "index_customers_on_business_id"
  end

  create_table "digital_products", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "external_id"
    t.string "kind"
    t.string "name"
    t.decimal "price"
    t.string "provider"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_digital_products_on_business_id"
  end

  create_table "human_escalations", force: :cascade do |t|
    t.decimal "actual_cost", precision: 10, scale: 2
    t.bigint "agent_run_id", null: false
    t.decimal "budget", precision: 10, scale: 2
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deadline"
    t.string "expertise"
    t.string "external_id"
    t.jsonb "provenance", default: {}, null: false
    t.string "provider"
    t.decimal "quoted_cost", precision: 10, scale: 2
    t.text "result"
    t.string "status", default: "quoting"
    t.text "task"
    t.datetime "updated_at", null: false
    t.index ["agent_run_id"], name: "index_human_escalations_on_agent_run_id"
    t.index ["business_id"], name: "index_human_escalations_on_business_id"
  end

  create_table "leads", force: :cascade do |t|
    t.text "body"
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "intent"
    t.datetime "last_message_at"
    t.string "source"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_leads_on_business_id"
    t.index ["customer_id"], name: "index_leads_on_customer_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "agent_action_id"
    t.text "body"
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.string "external_id"
    t.string "intent"
    t.string "provider"
    t.datetime "sent_at"
    t.string "status", default: "sent"
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "appointment_id"
    t.bigint "business_id", null: false
    t.string "checkout_url"
    t.datetime "created_at", null: false
    t.string "currency", default: "pln", null: false
    t.bigint "customer_id", null: false
    t.datetime "due_at"
    t.string "external_id"
    t.datetime "paid_at"
    t.string "provider", default: "stripe", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_payments_on_appointment_id"
    t.index ["business_id"], name: "index_payments_on_business_id"
    t.index ["customer_id"], name: "index_payments_on_customer_id"
  end

  create_table "services", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration_minutes"
    t.string "name"
    t.decimal "price"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_services_on_business_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  add_foreign_key "agent_actions", "agent_runs"
  add_foreign_key "agent_actions", "appointments"
  add_foreign_key "agent_actions", "businesses"
  add_foreign_key "agent_actions", "customers"
  add_foreign_key "agent_runs", "businesses"
  add_foreign_key "appointments", "businesses"
  add_foreign_key "appointments", "customers"
  add_foreign_key "appointments", "services"
  add_foreign_key "approval_requests", "agent_runs"
  add_foreign_key "approval_requests", "businesses"
  add_foreign_key "business_metrics", "businesses"
  add_foreign_key "business_policies", "businesses"
  add_foreign_key "conversations", "businesses"
  add_foreign_key "conversations", "customers"
  add_foreign_key "customers", "businesses"
  add_foreign_key "digital_products", "businesses"
  add_foreign_key "human_escalations", "agent_runs"
  add_foreign_key "human_escalations", "businesses"
  add_foreign_key "leads", "businesses"
  add_foreign_key "leads", "customers"
  add_foreign_key "messages", "conversations"
  add_foreign_key "payments", "appointments"
  add_foreign_key "payments", "businesses"
  add_foreign_key "payments", "customers"
  add_foreign_key "services", "businesses"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
