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

ActiveRecord::Schema.define(version: 20160815195858) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activist_matches", force: :cascade do |t|
    t.integer  "activist_id"
    t.integer  "match_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "activist_matches", ["activist_id"], name: "index_activist_matches_on_activist_id", using: :btree
  add_index "activist_matches", ["match_id"], name: "index_activist_matches_on_match_id", using: :btree

  create_table "activist_pressures", force: :cascade do |t|
    t.integer  "activist_id"
    t.integer  "widget_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "activist_pressures", ["activist_id"], name: "index_activist_pressures_on_activist_id", using: :btree
  add_index "activist_pressures", ["widget_id"], name: "index_activist_pressures_on_widget_id", using: :btree

  create_table "activists", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "email",           null: false
    t.string   "phone"
    t.string   "document_number"
    t.string   "document_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "zipcode"
    t.string   "street"
    t.string   "street_number"
    t.string   "complementary"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "activist_id"
  end

  add_index "addresses", ["activist_id"], name: "index_addresses_on_activist_id", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.integer  "mobilization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "bg_class"
    t.integer  "position"
    t.boolean  "hidden"
    t.text     "bg_image"
    t.string   "name"
    t.boolean  "menu_hidden"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "activist_id"
    t.string   "last_digits"
    t.string   "card_brand"
    t.string   "card_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "expiration_date"
  end

  add_index "credit_cards", ["activist_id"], name: "index_credit_cards_on_activist_id", using: :btree

  create_table "donations", force: :cascade do |t|
    t.integer  "widget_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "token"
    t.string   "payment_method"
    t.integer  "amount"
    t.string   "email"
    t.string   "card_hash"
    t.hstore   "customer"
    t.boolean  "skip",               default: false
    t.string   "transaction_id"
    t.string   "transaction_status"
    t.boolean  "subscription"
    t.string   "credit_card"
    t.integer  "activist_id"
    t.string   "subscription_id"
    t.integer  "period"
    t.integer  "plan_id"
  end

  add_index "donations", ["activist_id"], name: "index_donations_on_activist_id", using: :btree
  add_index "donations", ["customer"], name: "index_donations_on_customer", using: :gin
  add_index "donations", ["widget_id"], name: "index_donations_on_widget_id", using: :btree

  create_table "form_entries", force: :cascade do |t|
    t.integer  "widget_id"
    t.text     "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "form_entries", ["widget_id"], name: "index_form_entries_on_widget_id", using: :btree

  create_table "matches", force: :cascade do |t|
    t.integer  "widget_id"
    t.string   "first_choice"
    t.string   "second_choice"
    t.string   "goal_image"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "matches", ["widget_id"], name: "index_matches_on_widget_id", using: :btree

  create_table "mobilizations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "user_id"
    t.string   "color_scheme"
    t.string   "google_analytics_code"
    t.text     "goal"
    t.string   "facebook_share_title"
    t.text     "facebook_share_description"
    t.string   "header_font"
    t.string   "body_font"
    t.string   "facebook_share_image"
    t.string   "slug",                                   null: false
    t.string   "custom_domain"
    t.string   "twitter_share_text",         limit: 140
    t.integer  "organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name"
    t.string   "city"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "pagarme_recipient_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string   "transaction_status"
    t.string   "transaction_id"
    t.integer  "plan_id"
    t.integer  "donation_id"
    t.string   "subscription_id"
    t.integer  "activist_id"
    t.integer  "address_id"
    t.integer  "credit_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["donation_id"], name: "index_payments_on_donation_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "plan_id"
    t.string   "name"
    t.integer  "amount"
    t.integer  "days"
    t.text     "payment_methods", default: ["credit_card", "boleto"], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",                            null: false
    t.string   "uid",                    default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.text     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.boolean  "admin"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

  create_table "widgets", force: :cascade do |t|
    t.integer  "block_id"
    t.hstore   "settings"
    t.string   "kind"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "sm_size"
    t.integer  "md_size"
    t.integer  "lg_size"
    t.string   "mailchimp_segment_id"
    t.boolean  "action_community",     default: false
    t.datetime "exported_at"
  end

  add_foreign_key "activist_matches", "activists"
  add_foreign_key "activist_matches", "matches"
  add_foreign_key "activist_pressures", "activists"
  add_foreign_key "activist_pressures", "widgets"
  add_foreign_key "addresses", "activists"
  add_foreign_key "donations", "activists"
  add_foreign_key "donations", "widgets"
  add_foreign_key "form_entries", "widgets"
  add_foreign_key "matches", "widgets"
end
