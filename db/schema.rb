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

ActiveRecord::Schema[8.0].define(version: 2025_03_11_081451) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "prompts", force: :cascade do |t|
    t.text "title"
    t.text "url"
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "ai_processing_status", default: 0
    t.datetime "ai_processed_at"
    t.text "tags", default: [], array: true
    t.index ["url", "user_id"], name: "index_prompts_on_url_and_user_id", unique: true
    t.index ["user_id"], name: "index_prompts_on_user_id"
  end

  create_table "prompts_tags", id: false, force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.bigint "tag_id", null: false
    t.index ["prompt_id", "tag_id"], name: "index_prompts_tags_on_prompt_id_and_tag_id", unique: true
    t.index ["prompt_id"], name: "index_prompts_tags_on_prompt_id"
    t.index ["tag_id"], name: "index_prompts_tags_on_tag_id"
  end

  create_table "tag_suggestion_histories", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.bigint "user_id", null: false
    t.text "suggested_tags"
    t.datetime "suggested_at"
    t.integer "rating", default: 0
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "suggestion", default: "", null: false
    t.index ["prompt_id", "suggested_at"], name: "index_tag_suggestion_histories_on_prompt_id_and_suggested_at"
    t.index ["prompt_id"], name: "index_tag_suggestion_histories_on_prompt_id"
    t.index ["user_id"], name: "index_tag_suggestion_histories_on_user_id"
  end

  create_table "tag_suggestions", force: :cascade do |t|
    t.bigint "prompt_id", null: false
    t.string "name", null: false
    t.float "confidence", default: 0.0
    t.boolean "applied", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id", "name"], name: "index_tag_suggestions_on_prompt_id_and_name", unique: true
    t.index ["prompt_id"], name: "index_tag_suggestions_on_prompt_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["name", "user_id"], name: "index_tags_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "prompts", "users"
  add_foreign_key "prompts_tags", "prompts"
  add_foreign_key "prompts_tags", "tags"
  add_foreign_key "tag_suggestion_histories", "prompts"
  add_foreign_key "tag_suggestion_histories", "users"
  add_foreign_key "tag_suggestions", "prompts"
  add_foreign_key "tags", "users"
end
