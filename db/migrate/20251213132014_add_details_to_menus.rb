class AddDetailsToMenus < ActiveRecord::Migration[8.1]
  def change
    add_column :menus, :description, :text
    add_column :menus, :active, :boolean, default: true, null: false
    add_column :menus, :categories, :text, default: "[]", null: false
  end
end
