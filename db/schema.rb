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

ActiveRecord::Schema[8.0].define(version: 2025_08_28_013010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "shops", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 40, default: "未設定", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shops_on_user_id", unique: true
    t.check_constraint "description IS NULL OR char_length(description) <= 2000", name: "shops_description_length_chk"
  end

  create_table "user_identities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "provider", limit: 2, null: false
    t.text "provider_subject", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "provider_subject"], name: "index_user_identities_on_provider_and_subject", unique: true
    t.index ["user_id"], name: "index_user_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", null: false
    t.string "name", limit: 20
    t.integer "role", default: 0, null: false
    t.text "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
    t.check_constraint "char_length(email::text) <= 100", name: "users_email_maxlen_100"
    t.check_constraint "role = ANY (ARRAY[0, 5, 10])", name: "users_role_enum_values"
  end

  add_foreign_key "shops", "users"
  add_foreign_key "user_identities", "users"
end
