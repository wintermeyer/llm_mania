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

ActiveRecord::Schema[8.0].define(version: 2025_02_24_161015) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "llm_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "prompt_id", null: false
    t.uuid "llm_id", null: false
    t.integer "priority"
    t.integer "position"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "response_time_ms"
    t.index ["llm_id"], name: "index_llm_jobs_on_llm_id"
    t.index ["position"], name: "index_llm_jobs_on_position"
    t.index ["prompt_id"], name: "index_llm_jobs_on_prompt_id"
    t.index ["status"], name: "index_llm_jobs_on_status"
  end

  create_table "llms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "ollama_model"
    t.integer "size"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_llms_on_name", unique: true
    t.index ["ollama_model"], name: "index_llms_on_ollama_model", unique: true
  end

  create_table "prompt_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "prompt_id", null: false
    t.uuid "user_id", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_prompt_reports_on_prompt_id"
    t.index ["user_id"], name: "index_prompt_reports_on_user_id"
  end

  create_table "prompts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.text "content"
    t.boolean "private"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false, null: false
    t.boolean "flagged", default: false, null: false
    t.index ["status"], name: "index_prompts_on_status"
    t.index ["user_id"], name: "index_prompts_on_user_id"
  end

  create_table "ratings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "response_id", null: false
    t.uuid "user_id", null: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.index ["response_id"], name: "index_ratings_on_response_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "llm_job_id", null: false
    t.text "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_job_id"], name: "index_responses_on_llm_job_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "subscription_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subscription_id", null: false
    t.uuid "user_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_subscription_histories_on_subscription_id"
    t.index ["user_id"], name: "index_subscription_histories_on_user_id"
  end

  create_table "subscription_llms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subscription_id", null: false
    t.uuid "llm_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_id"], name: "index_subscription_llms_on_llm_id"
    t.index ["subscription_id"], name: "index_subscription_llms_on_subscription_id"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.integer "daily_prompt_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description", null: false
    t.integer "max_llm_requests_per_day", null: false
    t.integer "priority", null: false
    t.integer "max_prompt_length", null: false
    t.integer "price_cents", null: false
    t.boolean "private_prompts_allowed", default: false, null: false
    t.boolean "active", default: true, null: false
    t.index ["name"], name: "index_subscriptions_on_name", unique: true
  end

  create_table "user_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "gender", default: "other", null: false
    t.string "lang", default: "en", null: false
    t.boolean "active", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "password_digest", null: false
    t.uuid "current_role_id"
    t.index ["current_role_id"], name: "index_users_on_current_role_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "llm_jobs", "llms"
  add_foreign_key "llm_jobs", "prompts"
  add_foreign_key "prompt_reports", "prompts"
  add_foreign_key "prompt_reports", "users"
  add_foreign_key "prompts", "users"
  add_foreign_key "ratings", "responses"
  add_foreign_key "ratings", "users"
  add_foreign_key "responses", "llm_jobs"
  add_foreign_key "subscription_histories", "subscriptions"
  add_foreign_key "subscription_histories", "users"
  add_foreign_key "subscription_llms", "llms"
  add_foreign_key "subscription_llms", "subscriptions"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "users", "roles", column: "current_role_id"
end

