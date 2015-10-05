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

ActiveRecord::Schema.define(version: 20151004225807) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.integer  "reminder"
    t.integer  "users_id"
    t.integer  "classes_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "appointments", ["classes_id"], name: "index_appointments_on_classes_id", using: :btree
  add_index "appointments", ["users_id"], name: "index_appointments_on_users_id", using: :btree

  create_table "classes", force: :cascade do |t|
    t.string   "type"
    t.string   "level"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "duration"
    t.datetime "date"
    t.integer  "studios_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classes", ["studios_id"], name: "index_classes_on_studios_id", using: :btree

  create_table "filters", force: :cascade do |t|
    t.string   "class_type"
    t.string   "class_level"
    t.integer  "users_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "filters", ["users_id"], name: "index_filters_on_users_id", using: :btree

  create_table "studios", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "schedule_url"
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "image"
    t.string   "google_uid"
    t.string   "google_token"
    t.text     "availability"
    t.string   "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
