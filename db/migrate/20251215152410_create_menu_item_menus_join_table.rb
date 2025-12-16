class CreateMenuItemMenusJoinTable < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_item_menus do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.timestamps

      t.index [ :menu_id, :menu_item_id ], unique: true
    end
  end
end
