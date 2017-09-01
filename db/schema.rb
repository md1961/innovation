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

ActiveRecord::Schema.define(version: 20170901075019) do

  create_table "ages", force: :cascade do |t|
    t.integer "level",    null: false
    t.string  "name",     null: false
    t.string  "name_eng"
  end

  create_table "card_resources", force: :cascade do |t|
    t.integer "card_id"
    t.integer "resource_id"
    t.integer "resource_position_id"
  end

  add_index "card_resources", ["card_id"], name: "index_card_resources_on_card_id"
  add_index "card_resources", ["resource_id"], name: "index_card_resources_on_resource_id"
  add_index "card_resources", ["resource_position_id"], name: "index_card_resources_on_resource_position_id"

  create_table "cards", force: :cascade do |t|
    t.integer  "age_id"
    t.integer  "color_id"
    t.string   "title",      null: false
    t.string   "title_eng"
    t.string   "effect",     null: false
    t.string   "effect_eng"
    t.binary   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cards", ["age_id"], name: "index_cards_on_age_id"
  add_index "cards", ["color_id"], name: "index_cards_on_color_id"

  create_table "colors", force: :cascade do |t|
    t.string "name"
    t.string "name_eng", null: false
    t.string "rgb",      null: false
  end

  create_table "resource_positions", force: :cascade do |t|
    t.string  "name"
    t.string  "name_eng"
    t.string  "abbr"
    t.string  "abbr_eng"
    t.boolean "is_left",   null: false
    t.boolean "is_right",  null: false
    t.boolean "is_bottom", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string  "name",     null: false
    t.string  "name_eng"
    t.integer "color_id"
    t.binary  "image"
  end

  add_index "resources", ["color_id"], name: "index_resources_on_color_id"

end
