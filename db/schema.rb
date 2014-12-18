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

ActiveRecord::Schema.define(version: 20141218023340) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: true do |t|
    t.string   "name"
    t.float    "grams_total"
    t.float    "serving_size"
    t.float    "grams_per_serving"
    t.float    "calories"
    t.float    "calories_from_fat"
    t.float    "total_fat"
    t.float    "saturated_fat"
    t.float    "trans_fat"
    t.float    "cholesterol"
    t.float    "sodium"
    t.float    "total_carb"
    t.float    "dietary_fiber"
    t.float    "sugar"
    t.float    "protein"
    t.float    "vitamin_a"
    t.float    "vitamin_c"
    t.float    "calcium"
    t.float    "vitamin_d"
    t.float    "phosphorus"
    t.boolean  "kosher"
    t.boolean  "gluten_free"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", force: true do |t|
    t.integer  "user_id"
    t.datetime "expires_at"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["token"], name: "index_tokens_on_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_hash"
    t.boolean  "is_admin"
    t.string   "picture_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
