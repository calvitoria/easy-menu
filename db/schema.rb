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

ActiveRecord::Schema[8.1].define(version: 2025_12_17_020949) do
  create_table "import_audit_logs", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "details"
    t.text "error_message"
    t.integer "failed_records", default: 0
    t.string "file_name"
    t.string "import_type", null: false
    t.datetime "started_at"
    t.string "status", null: false
    t.integer "successful_records", default: 0
    t.integer "total_records", default: 0
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_import_audit_logs_on_created_at"
    t.index ["import_type"], name: "index_import_audit_logs_on_import_type"
    t.index ["status"], name: "index_import_audit_logs_on_status"
  end

  create_table "menu_item_menus", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "menu_id", null: false
    t.integer "menu_item_id", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id", "menu_item_id"], name: "index_menu_item_menus_on_menu_id_and_menu_item_id", unique: true
    t.index ["menu_id"], name: "index_menu_item_menus_on_menu_id"
    t.index ["menu_item_id"], name: "index_menu_item_menus_on_menu_item_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.text "categories", default: "[]", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.decimal "price", precision: 8, scale: 2, default: "0.0"
    t.boolean "spicy", default: false, null: false
    t.datetime "updated_at", null: false
    t.boolean "vegan", default: false, null: false
    t.boolean "vegetarian", default: false, null: false
    t.index "LOWER(name)", name: "index_menu_items_on_lowercase_name", unique: true
  end

  create_table "menus", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.text "categories", default: "[]", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.bigint "restaurant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurant_id"], name: "index_menus_on_restaurant_id"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index "LOWER(name)", name: "index_restaurants_on_lowercase_name", unique: true
    t.index ["email"], name: "index_restaurants_on_email"
    t.index ["name"], name: "index_restaurants_on_name"
  end

  add_foreign_key "menu_item_menus", "menu_items"
  add_foreign_key "menu_item_menus", "menus"
  add_foreign_key "menus", "restaurants"
end
