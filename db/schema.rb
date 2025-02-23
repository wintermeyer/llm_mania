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

ActiveRecord::Schema[8.0].define(version: 2025_02_23_154531) do
# Could not dump table "daily_usages" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "llm_jobs" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "llms" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "prompt_reports" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "prompts" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "ratings" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "responses" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "subscription_histories" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "subscription_llms" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "subscriptions" because of following StandardError
#   Unknown type 'uuid' for column 'id'


# Could not dump table "users" because of following StandardError
#   Unknown type 'uuid' for column 'id'


  add_foreign_key "daily_usages", "users"
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
  add_foreign_key "users", "current_subscriptions"
end
