class AddUniqueIndexToRestaurantName < ActiveRecord::Migration[8.1]
    def up
    duplicate_names = connection.select_values(<<~SQL)
      SELECT LOWER(name) as lower_name
      FROM restaurants
      GROUP BY LOWER(name)
      HAVING COUNT(*) > 1
    SQL

    duplicate_names.each do |lower_name|
      find_sql = sanitize_sql([
        "SELECT id, name, created_at FROM restaurants WHERE LOWER(name) = :name ORDER BY created_at ASC, id ASC",
        { name: lower_name }
      ])

      records = connection.execute(find_sql)

      records.each_with_index do |record, index|
        next if index == 0

        id = record['id']
        current_name = record['name']
        new_name = "#{current_name}_#{id}"

        update_sql = sanitize_sql([
          "UPDATE restaurants SET name = :new_name WHERE id = :id",
          { new_name: new_name, id: id }
        ])

        connection.execute(update_sql)
      end
    end

    add_index :restaurants, 'LOWER(name)', unique: true, name: 'index_restaurants_on_lowercase_name'
  end

  def down
    remove_index :restaurants, name: 'index_restaurants_on_lowercase_name'
  end
end
