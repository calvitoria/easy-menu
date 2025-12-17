class RemoveUniquenessFromRestaurantEmail < ActiveRecord::Migration[8.1]
  def change
    remove_index :restaurants, name: :index_restaurants_on_email
    add_index :restaurants, :email, name: :index_restaurants_on_email
  end
end
