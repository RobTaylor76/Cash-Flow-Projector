# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20121106214634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_accounts", force: true do |t|
    t.string   "name"
    t.integer  "main_ledger_account_id"
    t.integer  "charges_ledger_account_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_accounts", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledger_entries", force: true do |t|
    t.integer  "ledger_account_id",                                        null: false
    t.integer  "user_id",                                                  null: false
    t.integer  "transaction_id"
    t.decimal  "debit",             precision: 14, scale: 2, default: 0.0
    t.decimal  "credit",            precision: 14, scale: 2, default: 0.0
    t.date     "date",                                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recurring_transactions", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "reference",                                 default: ""
    t.integer  "user_id"
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "percentage_of_id"
    t.integer  "frequency_id"
    t.decimal  "amount",           precision: 14, scale: 2, default: 0.0
    t.decimal  "percentage",       precision: 14, scale: 8, default: 0.0
    t.integer  "day_of_month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_frequencies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: true do |t|
    t.integer  "user_id"
    t.string   "reference",   default: ""
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.string   "source_type"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
