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

  test "validates presence of email" do
    restaurant = build(:restaurant, email: nil)
    assert_not restaurant.valid?, "Restaurant should not be valid without an email"
    assert_includes restaurant.errors[:email], "can't be blank"
  end

  test "validates uniqueness of email" do
    existing_restaurant = create(:restaurant)
    restaurant = build(:restaurant, email: existing_restaurant.email)
    assert_not restaurant.valid?, "Restaurant should not be valid with a duplicate email"
    assert_includes restaurant.errors[:email], "has already been taken"
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
end
