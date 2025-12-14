class AddRestaurantIdToMenus < ActiveRecord::Migration[8.1]
  def up
    add_column :menus, :restaurant_id, :bigint
    add_index :menus, :restaurant_id

    if Menu.any?
      ActiveRecord::Base.transaction do
        default_restaurant = Restaurant.create!(
          name: "Default Restaurant",
          email: "default_restaurant_@example.com",
          description: "Auto-created for existing menus",
          address: "System generated"
        )

        Menu.update_all(restaurant_id: default_restaurant.id)

        if Menu.where(restaurant_id: nil).any?
          raise "Failed to migrate all menus to have restaurant_id"
        end
      end
    end

    add_foreign_key :menus, :restaurants
    change_column_null :menus, :restaurant_id, false
  end

  def down
    change_column_null :menus, :restaurant_id, true
    remove_foreign_key :menus, :restaurants
    remove_index :menus, :restaurant_id
    remove_column :menus, :restaurant_id
    Restaurant.where("email LIKE ?", "default_restaurant_%@example.com").destroy_all
  end
end
