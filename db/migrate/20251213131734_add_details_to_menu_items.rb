class AddDetailsToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :vegan, :boolean, default: false, null: false
    add_column :menu_items, :vegetarian, :boolean, default: false, null: false
    add_column :menu_items, :categories, :text, default: "[]", null: false
    add_column :menu_items, :description, :text
    add_column :menu_items, :spicy, :boolean, default: false, null: false
  end
end
