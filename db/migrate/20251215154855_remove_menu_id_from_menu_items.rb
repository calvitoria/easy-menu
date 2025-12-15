class RemoveMenuIdFromMenuItems < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :menu_items, :menus
    remove_column :menu_items, :menu_id
    remove_index :menu_items, name: "index_menu_items_on_menu_id" if index_exists?(:menu_items, :menu_id)
  end

  def down
    add_column :menu_items, :menu_id, :integer
    add_index :menu_items, :menu_id
    add_foreign_key :menu_items, :menus
  end
end
