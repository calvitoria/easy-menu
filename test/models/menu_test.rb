require "test_helper"

class MenuTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
  end

  test "can create, update, and destroy a menu with required fields" do
    menu = create(:menu, restaurant: @restaurant, name: "Breakfast")
    assert menu.valid?, "Menu should be valid with a restaurant and name"
    assert menu.id.present?, "Menu should have an id"
    assert_equal "Breakfast", menu.name
    assert menu.created_at.present?, "Menu should have created_at"
    assert menu.updated_at.present?, "Menu should have updated_at"
    assert_equal @restaurant, menu.restaurant

    menu.update(name: "Brunch")
    assert_equal "Brunch", menu.reload.name

    menu_id = menu.id
    assert menu.destroy, "Menu should be destroyed"
    assert_nil Menu.find_by(id: menu_id), "Menu should not exist after destroy"
  end

  test "menu has many menu_items" do
    menu = create(:menu, restaurant: @restaurant, name: "Lunch")
    item1 = create(:menu_item, menu: menu, name: "Burger")
    item2 = create(:menu_item, menu: menu, name: "Fries")
    assert_equal 2, menu.menu_items.count
    assert_includes menu.menu_items, item1
    assert_includes menu.menu_items, item2
  end

  test "destroying menu destroys its menu_items" do
    menu = create(:menu, restaurant: @restaurant, name: "Snacks")
    menu_item = create(:menu_item, menu: menu, name: "Chips")
    menu.destroy
    assert_nil MenuItem.find_by(id: menu_item.id), "MenuItem should be destroyed when menu is destroyed"
  end

  test "cannot create menu without a name" do
    menu = Menu.new(restaurant: @restaurant)
    assert_not menu.save, "Menu should not be saved without a name"
    assert_includes menu.errors[:name], "can't be blank"
  end

  test "cannot create menu without a restaurant" do
    menu = Menu.new(name: "Dinner")
    assert_not menu.save, "Menu should not be saved without a restaurant"
    assert_includes menu.errors[:restaurant], "must exist"
    assert_includes menu.errors[:restaurant_id], "can't be blank"
  end

  test "categories can be set and retrieved as array" do
    menu = create(:menu, restaurant: @restaurant, name: "Specials", categories: [ "vegan", "gluten-free" ])
    assert_equal [ "vegan", "gluten-free" ], menu.categories
  end

  test "categories defaults to empty array" do
    menu = create(:menu, restaurant: @restaurant, name: "Sides")
    assert_equal [], menu.categories
  end

  test "menu responds to categories as array" do
    menu = create(:menu, restaurant: @restaurant, name: "Appetizers", categories: [ "spicy" ])
    assert_kind_of Array, menu.categories
  end

  test "menu belongs to a restaurant" do
    menu = create(:menu, restaurant: @restaurant)
    assert_instance_of Restaurant, menu.restaurant
    assert_equal @restaurant, menu.restaurant
  end
end
