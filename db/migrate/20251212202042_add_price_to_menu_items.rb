class AddPriceToMenuItems < ActiveRecord::Migration[8.1]
  def change
    add_column :menu_items, :price, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
