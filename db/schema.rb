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

ActiveRecord::Schema.define(version: 20190114193109) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analysis_codes", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "balance_corrections", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ledger_account_id"
    t.decimal  "balance",                       precision: 14, scale: 2, default: 0.0
    t.decimal  "correction",                    precision: 14, scale: 2, default: 0.0
    t.date     "date"
    t.date     "correction_date"
    t.string   "reference",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.integer  "main_ledger_account_id"
    t.integer  "charges_ledger_account_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "reference",     limit: 255,                          default: ""
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.string   "source_type",   limit: 255
    t.decimal  "amount",                    precision: 14, scale: 2, default: 0.0
    t.string   "import_sig",    limit: 255
    t.boolean  "approximation",                                      default: false
  end

  add_index "financial_transactions", ["user_id", "date"], name: "transactions_user_date_idx", using: :btree
  add_index "financial_transactions", ["user_id", "import_sig"], name: "transactions_user_import_sig_idx", using: :btree
  add_index "financial_transactions", ["user_id"], name: "transactions_user_id_fk", using: :btree

  create_table "ledger_accounts", force: :cascade do |t|
    t.integer  "user_id",                  null: false
    t.string   "name",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "control_name", limit: 255
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.integer  "ledger_account_id",                                               null: false
    t.integer  "user_id",                                                         null: false
    t.integer  "financial_transaction_id"
    t.decimal  "debit",                    precision: 14, scale: 2, default: 0.0
    t.decimal  "credit",                   precision: 14, scale: 2, default: 0.0
    t.date     "date",                                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "analysis_code_id"
  end

  add_index "ledger_entries", ["ledger_account_id", "date"], name: "lgr_entries_ledger_account_date_idx", using: :btree
  add_index "ledger_entries", ["ledger_account_id"], name: "lgr_entries_ledger_account_fk", using: :btree
  add_index "ledger_entries", ["user_id", "analysis_code_id"], name: "le_user_analysis_code_idx", using: :btree

  create_table "recurring_transactions", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "reference",         limit: 255,                          default: ""
    t.integer  "user_id"
    t.integer  "from_id"
    t.integer  "to_id"
    t.integer  "percentage_of_id"
    t.integer  "frequency_id"
    t.decimal  "amount",                        precision: 14, scale: 2, default: 0.0
    t.decimal  "percentage",                    precision: 14, scale: 8, default: 0.0
    t.integer  "day_of_month"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "working_days_only",                                      default: true
    t.boolean  "approximation",                                          default: true
    t.integer  "analysis_code_id"
  end

  create_table "statement_imports", force: :cascade do |t|
    t.integer  "ledger_account_id",             null: false
    t.integer  "user_id",                       null: false
    t.date     "date",                          null: false
    t.date     "from"
    t.date     "to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_name",         limit: 255
  end

  create_table "transaction_frequencies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
