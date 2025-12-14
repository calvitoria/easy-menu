class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.references :menu, null: false, foreign_key: true

      t.timestamps
    end
  end
end
