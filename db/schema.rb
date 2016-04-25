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

ActiveRecord::Schema.define(version: 20160425102822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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

  create_table "donations", force: :cascade do |t|
    t.integer  "widget_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "token"
    t.string   "payment_method"
    t.integer  "amount"
    t.string   "email"
  end

  add_index "donations", ["widget_id"], name: "index_donations_on_widget_id", using: :btree

  create_table "form_entries", force: :cascade do |t|
    t.integer  "widget_id"
    t.text     "fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "form_entries", ["widget_id"], name: "index_form_entries_on_widget_id", using: :btree

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
  end

  add_foreign_key "donations", "widgets"
  add_foreign_key "form_entries", "widgets"
end
