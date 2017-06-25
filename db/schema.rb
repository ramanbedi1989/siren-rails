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

ActiveRecord::Schema.define(version: 20170625114902) do

  create_table "emergency_routes", force: :cascade do |t|
    t.text     "route_json"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "user_id"
    t.boolean  "active",              default: false
    t.integer  "current_location_id"
    t.integer  "sufferer_id"
    t.integer  "healer_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "location_type"
    t.integer  "user_id"
    t.integer  "emergency_route_id"
    t.integer  "loc_index"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "light_status",       default: false
  end

  create_table "rails_push_notifications_apns_apps", force: :cascade do |t|
    t.text     "apns_dev_cert"
    t.text     "apns_prod_cert"
    t.boolean  "sandbox_mode"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "rails_push_notifications_gcm_apps", force: :cascade do |t|
    t.string   "gcm_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_mpns_apps", force: :cascade do |t|
    t.text     "cert"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rails_push_notifications_notifications", force: :cascade do |t|
    t.text     "destinations"
    t.integer  "app_id"
    t.string   "app_type"
    t.text     "data"
    t.text     "results"
    t.integer  "success"
    t.integer  "failed"
    t.boolean  "sent",         default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["app_id", "app_type", "sent"], name: "app_and_sent_index_on_rails_push_notifications"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "auth_token",             default: ""
    t.string   "category"
    t.string   "device_id"
    t.boolean  "busy",                   default: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
