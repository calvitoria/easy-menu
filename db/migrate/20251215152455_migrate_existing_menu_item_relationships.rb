class MigrateExistingMenuItemRelationships < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      INSERT INTO menu_item_menus (menu_id, menu_item_id, created_at, updated_at)
      SELECT menu_id, id, created_at, updated_at
      FROM menu_items
      WHERE menu_id IS NOT NULL
    SQL
  end

  def down
    execute "DELETE FROM menu_item_menus"
  end
end
