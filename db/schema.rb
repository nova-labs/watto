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

ActiveRecord::Schema[7.0].define(version: 2022_03_16_161508) do
  create_table "credentials", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider"
    t.string "token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.boolean "expires"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credentials_on_user_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.integer "uid"
    t.string "url"
    t.string "display_name"
    t.integer "contact_uid"
    t.integer "event_id", null: false
    t.integer "user_id"
    t.boolean "paid"
    t.integer "registration_fee"
    t.boolean "on_waitlist"
    t.string "registration_type"
    t.datetime "registration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "uid"
    t.string "url"
    t.string "event_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "location"
    t.boolean "registration_enabled"
    t.text "description"
    t.string "name"
    t.boolean "end_time_specified"
    t.boolean "start_time_specified"
    t.string "access_level"
    t.boolean "registrations_limit"
    t.integer "pending_registrations_count"
    t.integer "confirmed_registrations_count"
    t.integer "checked_in_attendees_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_allowed_values", force: :cascade do |t|
    t.integer "uid"
    t.string "label"
    t.string "value"
    t.string "system_code"
    t.boolean "selected_by_default"
    t.integer "position"
    t.integer "field_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_field_allowed_values_on_field_id"
    t.index ["value"], name: "index_field_allowed_values_on_value"
  end

  create_table "field_user_values", force: :cascade do |t|
    t.string "value"
    t.string "label"
    t.string "system_code"
    t.integer "user_id", null: false
    t.integer "field_id"
    t.integer "field_allowed_value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_allowed_value_id"], name: "index_field_user_values_on_field_allowed_value_id"
    t.index ["field_id"], name: "index_field_user_values_on_field_id"
    t.index ["user_id", "value", "system_code"], name: "index_field_user_values_on_user_id_and_value_and_system_code"
    t.index ["user_id"], name: "index_field_user_values_on_user_id"
  end

  create_table "fields", force: :cascade do |t|
    t.string "url"
    t.integer "uid"
    t.string "access"
    t.string "description"
    t.string "member_access"
    t.boolean "member_only"
    t.boolean "built_in"
    t.boolean "support_search"
    t.boolean "editable"
    t.boolean "admin_only"
    t.string "field_type"
    t.string "field_name"
    t.boolean "system"
    t.string "field_instructions"
    t.integer "max_length"
    t.integer "order"
    t.string "display_type"
    t.string "system_code"
    t.boolean "required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_code"], name: "index_fields_on_system_code", unique: true
    t.index ["uid"], name: "index_fields_on_uid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "account_administrator"
    t.boolean "admin"
    t.boolean "membership_enabled"
    t.integer "membership_level_id"
    t.string "membership_level_name"
    t.string "membership_level_url"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "name"
    t.string "provider"
    t.string "status"
    t.string "uid"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "badge_number"
    t.boolean "archived"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "credentials", "users"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "users"
  add_foreign_key "field_allowed_values", "fields"
  add_foreign_key "field_user_values", "field_allowed_values"
  add_foreign_key "field_user_values", "fields"
  add_foreign_key "field_user_values", "users"
end
