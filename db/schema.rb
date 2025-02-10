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

ActiveRecord::Schema[8.0].define(version: 2025_02_10_100917) do
  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "llm_models", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "size", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ollama_name", null: false
    t.index ["is_active"], name: "index_llm_models_on_is_active"
    t.index ["name"], name: "index_llm_models_on_name", unique: true
    t.index ["ollama_name"], name: "index_llm_models_on_ollama_name", unique: true
    t.index ["slug"], name: "index_llm_models_on_slug", unique: true
  end

  create_table "plan_llm_models", force: :cascade do |t|
    t.integer "plan_id", null: false
    t.integer "llm_model_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_model_id"], name: "index_plan_llm_models_on_llm_model_id"
    t.index ["plan_id", "llm_model_id"], name: "index_plan_llm_models_on_plan_id_and_llm_model_id", unique: true
    t.index ["plan_id"], name: "index_plan_llm_models_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.text "description"
    t.index ["name"], name: "index_plans_on_name", unique: true
    t.index ["slug"], name: "index_plans_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "is_admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "plan_llm_models", "llm_models"
  add_foreign_key "plan_llm_models", "plans"
end
