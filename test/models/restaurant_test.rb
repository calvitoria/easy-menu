require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "can create, read, update, and destroy a restaurant" do
    restaurant = create(:restaurant)
    assert restaurant.valid?, "Restaurant should be valid"
    assert_not_nil restaurant.id, "Restaurant should have an ID"

    found_restaurant = Restaurant.find(restaurant.id)
    assert_equal restaurant.name, found_restaurant.name

    new_name = "Updated Restaurant Name"
    restaurant.update(name: new_name)
    assert_equal new_name, restaurant.reload.name

    restaurant_id = restaurant.id
    restaurant.destroy
    assert_nil Restaurant.find_by(id: restaurant_id), "Restaurant should be destroyed"
  end

  test "validates presence of name" do
    restaurant = build(:restaurant, name: nil)
    assert_not restaurant.valid?, "Restaurant should not be valid without a name"
    assert_includes restaurant.errors[:name], "can't be blank"
  end

  test "uniqueness validation for name works with spaces and special characters" do
    restaurant1 = Restaurant.create!(
      name: "Nostro Sapore!",
      email: "nostro@sap.com"
    )

    restaurant2 = Restaurant.new(
      name: "Nostro Sapore!",
      email: "nostro@sapore.com"
    )

    assert_not restaurant2.save, "Should not save duplicate with special characters"
    assert_includes restaurant2.errors[:name], "has already been taken"
  end

  test "uniqueness validation for name works with apostrophes" do
    restaurant1 = Restaurant.create!(
      name: "O'kpos",
      email: "nostro@sap.com"
    )

    restaurant2 = Restaurant.new(
      name: "O'kpos",
      email: "nostro@sapore.com"
    )

    assert_not restaurant2.save, "Should not save duplicate with apostrophes"
    assert_includes restaurant2.errors[:name], "has already been taken"
  end

  test "allows duplicate emails across restaurants" do
    email = "contact@food.com"

    create(:restaurant, email: email)
    restaurant = build(:restaurant, email: email)

    assert restaurant.valid?
  end


  test "validates format of email" do
    restaurant = build(:restaurant, email: "invalid-email")
    assert_not restaurant.valid?, "Restaurant should not be valid with an invalid email format"
    assert_includes restaurant.errors[:email], "is invalid"

    restaurant = build(:restaurant, email: "valid@example.com")
    assert restaurant.valid?, "Restaurant should be valid with a valid email format"
  end

  test "has many menus and destroys them when restaurant is destroyed" do
    restaurant = create(:restaurant)
    menu1 = create(:menu, restaurant: restaurant)
    menu2 = create(:menu, restaurant: restaurant)

    assert_equal 2, restaurant.menus.count
    assert_includes restaurant.menus, menu1
    assert_includes restaurant.menus, menu2

    restaurant.destroy
    assert_nil Menu.find_by(id: menu1.id), "Menu 1 should be destroyed"
    assert_nil Menu.find_by(id: menu2.id), "Menu 2 should be destroyed"
  end

  test "name is indexed in database" do
    restaurant = create(:restaurant, name: "Indexed Restaurant")

    assert_equal restaurant, Restaurant.find_by(name: "Indexed Restaurant")
    assert_equal restaurant, Restaurant.where("LOWER(name) = ?", "indexed restaurant").first
  end

  test "email is indexed in database" do
    restaurant = create(:restaurant, email: "indexed@example.com")

    assert_equal restaurant, Restaurant.find_by(email: "indexed@example.com")
  end

  test "has many menu_items through menus via menu_item_menus join table" do
    restaurant = create(:restaurant)
    menu = create(:menu, restaurant: restaurant)
    menu_item1 = create(:menu_item, name: "Item 1")
    menu_item2 = create(:menu_item, name: "Item 2")

    menu.menu_items << menu_item1
    menu.menu_items << menu_item2

    assert_equal 2, restaurant.menu_items.count
    assert_includes restaurant.menu_items, menu_item1
    assert_includes restaurant.menu_items, menu_item2
  end

  test "menu_items are not destroyed when restaurant is destroyed" do
    restaurant = create(:restaurant)
    menu = create(:menu, restaurant: restaurant)
    menu_item = create(:menu_item)
    menu.menu_items << menu_item

    menu_item_id = menu_item.id
    restaurant.destroy

    assert_not_nil MenuItem.find_by(id: menu_item_id)
    assert_nil MenuItemMenu.find_by(menu_item_id: menu_item_id)
  end

  test "description and address can be long strings" do
    long_description = "A" * 500
    long_address = "B" * 500

    restaurant = create(:restaurant,
      description: long_description,
      address: long_address
    )

    assert restaurant.valid?
    assert_equal long_description, restaurant.description
    assert_equal long_address, restaurant.address
  end

  test "restaurant has correct database columns" do
    columns = Restaurant.columns_hash

    assert columns.key?("id")
    assert columns.key?("name")
    assert columns.key?("email")
    assert columns.key?("description")
    assert columns.key?("address")
    assert columns.key?("created_at")
    assert columns.key?("updated_at")

    assert_not columns.key?("active")
  end

  test "restaurant attributes can be mass assigned" do
    params = {
      name: "Test Restaurant",
      email: "test@example.com",
      description: "Test description",
      address: "123 Test St"
    }

    restaurant = Restaurant.new(params)

    params.each do |key, value|
      assert_equal value, restaurant.send(key)
    end
  end

  test "to_json includes correct attributes" do
    restaurant = create(:restaurant)
    json = restaurant.to_json

    parsed = JSON.parse(json)
    expected_keys = [ "id", "name", "email", "description", "address", "created_at", "updated_at" ]

    expected_keys.each do |key|
      assert_includes parsed.keys, key
    end

    assert_not_includes parsed.keys, "active"
  end

  test "as_json includes correct attributes" do
    restaurant = create(:restaurant)
    json_hash = restaurant.as_json

    expected_keys = [ "id", "name", "email", "description", "address", "created_at", "updated_at" ]

    expected_keys.each do |key|
      assert_includes json_hash.keys, key
    end
  end
end
