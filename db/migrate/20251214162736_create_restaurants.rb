class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :email
      t.string :description
      t.string :address

      t.timestamps
    end

    add_index :restaurants, :email, unique: true
    add_index :restaurants, :name
  end
end
