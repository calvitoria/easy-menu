class RemoveUnusedCategoryColumn < ActiveRecord::Migration[8.1]
  def change
    remove_column :menu_items, :category, :string
  end
end
