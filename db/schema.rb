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

ActiveRecord::Schema.define(version: 2022_01_22_143655) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "account_login_change_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "login", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_otp_keys", force: :cascade do |t|
    t.string "key", null: false
    t.integer "num_failures", default: 0, null: false
    t.datetime "last_use", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_password_hashes", force: :cascade do |t|
    t.string "password_hash", null: false
  end

  create_table "account_password_reset_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "account_recovery_codes", primary_key: ["id", "code"], force: :cascade do |t|
    t.bigint "id", null: false
    t.string "code", null: false
  end

  create_table "account_remember_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "deadline", null: false
  end

  create_table "account_verification_keys", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "requested_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "email_last_sent", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "accounts", force: :cascade do |t|
    t.citext "email", null: false
    t.string "status", default: "unverified", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true, where: "((status)::text = ANY ((ARRAY['unverified'::character varying, 'verified'::character varying])::text[]))"
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.integer "account_id"
    t.string "name", null: false
    t.string "description", null: false
    t.string "homepage_url", null: false
    t.string "redirect_uri", null: false
    t.string "client_id", null: false
    t.string "client_secret", null: false
    t.string "scopes", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["client_id"], name: "index_oauth_applications_on_client_id", unique: true
    t.index ["client_secret"], name: "index_oauth_applications_on_client_secret", unique: true
  end

  create_table "oauth_grants", force: :cascade do |t|
    t.integer "account_id"
    t.integer "oauth_application_id"
    t.string "code", null: false
    t.datetime "expires_in", null: false
    t.string "redirect_uri"
    t.datetime "revoked_at"
    t.string "scopes", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "access_type", default: "offline", null: false
    t.index ["oauth_application_id", "code"], name: "index_oauth_grants_on_oauth_application_id_and_code", unique: true
  end

  create_table "oauth_tokens", force: :cascade do |t|
    t.integer "account_id"
    t.integer "oauth_grant_id"
    t.integer "oauth_token_id"
    t.integer "oauth_application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.datetime "expires_in", null: false
    t.datetime "revoked_at"
    t.string "scopes", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_posts_on_account_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_profiles_on_account_id"
  end

  add_foreign_key "account_login_change_keys", "accounts", column: "id"
  add_foreign_key "account_otp_keys", "accounts", column: "id"
  add_foreign_key "account_password_hashes", "accounts", column: "id"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id"
  add_foreign_key "account_recovery_codes", "accounts", column: "id"
  add_foreign_key "account_remember_keys", "accounts", column: "id"
  add_foreign_key "account_verification_keys", "accounts", column: "id"
  add_foreign_key "oauth_applications", "accounts"
  add_foreign_key "oauth_grants", "accounts"
  add_foreign_key "oauth_grants", "oauth_applications"
  add_foreign_key "oauth_tokens", "accounts"
  add_foreign_key "oauth_tokens", "oauth_applications"
  add_foreign_key "oauth_tokens", "oauth_grants"
  add_foreign_key "oauth_tokens", "oauth_tokens"
  add_foreign_key "posts", "accounts"
  add_foreign_key "profiles", "accounts"
end
