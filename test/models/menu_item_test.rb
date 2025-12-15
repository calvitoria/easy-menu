require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
    @menu = create(:menu, restaurant: @restaurant)
  end

  test "can create, update, and destroy a menu_item with required fields" do
    menu_item = MenuItem.new(name: "Coffee", menu: @menu)
    assert menu_item.save, "MenuItem should be saved"
    assert menu_item.id.present?, "MenuItem should have an id"
    assert menu_item.price.present?, "MenuItem should have an price"
    assert_equal @menu.id, menu_item.menu_id, "MenuItem should have correct menu_id"
    assert_equal "Coffee", menu_item.name
    assert menu_item.created_at.present?, "MenuItem should have created_at"
    assert menu_item.updated_at.present?, "MenuItem should have updated_at"

    menu_item.update(name: "Tea")
    assert_equal "Tea", menu_item.reload.name

    menu_item_id = menu_item.id
    assert menu_item.destroy, "MenuItem should be destroyed"
    assert_nil MenuItem.find_by(id: menu_item_id), "MenuItem should not exist after destroy"
  end

  test "menu_item has default price of 0.0" do
    menu_item = @menu.menu_items.create!(name: "Cake")
    assert_equal BigDecimal("0.0"), menu_item.price, "MenuItem should have default price of 0.0"
  end

  test "cannot create menu_item without menu" do
    menu_item = MenuItem.new(name: "Orphan Item")
    assert_not menu_item.save, "MenuItem should not be saved without a menu"
    assert_includes menu_item.errors[:menu], "must exist"
  end

  test "menu_item belongs to menu" do
    menu_item = @menu.menu_items.create!(name: "Steak")
    assert_equal @menu, menu_item.menu
  end

  test "cannot create menu_item without a name" do
    menu_item = @menu.menu_items.new
    assert_not menu_item.save, "MenuItem should not be saved without a name"
    assert_includes menu_item.errors[:name], "can't be blank"
  end

  test "cannot create menu_item without menu_id" do
    menu_item = MenuItem.new(name: "No Menu")
    assert_not menu_item.save, "MenuItem should not be saved without menu_id"
    assert_includes menu_item.errors[:menu_id], "can't be blank"
  end

  test "categories can be set and retrieved as array" do
    menu_item = @menu.menu_items.create!(name: "Soup", categories: [ "vegan", "starter" ])
    assert_equal [ "vegan", "starter" ], menu_item.categories
  end

  test "categories defaults to empty array" do
    menu_item = @menu.menu_items.create!(name: "Fries")
    assert_equal [], menu_item.categories
  end

  test "menu_item responds to categories as array" do
    menu_item = @menu.menu_items.create!(name: "Wings", categories: [ "spicy" ])
    assert_kind_of Array, menu_item.categories
  end

  test "menu item can access restaurant through menu" do
    menu_item = @menu.menu_items.create!(name: "Test Item")
    assert_equal @restaurant, menu_item.menu.restaurant
  end

  test "cannot create menu_item with duplicate name in same menu" do
    menu_item1 = @menu.menu_items.create!(name: "Burger")
    menu_item2 = @menu.menu_items.new(name: "Burger")

    assert_not menu_item2.save, "MenuItem with duplicate name should not be saved"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "cannot create menu_item with duplicate name case-insensitive in same menu" do
    menu_item1 = @menu.menu_items.create!(name: "Burger")
    menu_item2 = @menu.menu_items.new(name: "burger")  # lowercase

    assert_not menu_item2.save, "MenuItem with case-insensitive duplicate name should not be saved"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "cannot create menu_item with same name in different menus" do
    menu_item1 = @menu.menu_items.create!(name: "Pizza")

    menu2 = create(:menu, restaurant: @restaurant)
    menu_item2 = menu2.menu_items.new(name: "Pizza")

    assert_not menu_item2.save, "MenuItem with same name in different menu should NOT be saved (global uniqueness)"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "cannot create menu_item with same name in different restaurants" do
    menu_item1 = @menu.menu_items.create!(name: "Salad")

    restaurant2 = create(:restaurant)
    menu2 = create(:menu, restaurant: restaurant2)
    menu_item2 = menu2.menu_items.new(name: "Salad")

    assert_not menu_item2.save, "MenuItem with same name in different restaurant should NOT be saved (global uniqueness)"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "can update menu_item to existing name if it's the same record" do
    menu_item = @menu.menu_items.create!(name: "Original Name")
    assert menu_item.update(name: "Original Name"), "Should be able to update with same name"
  end

  test "cannot update menu_item to duplicate name of another item in same menu" do
    menu_item1 = @menu.menu_items.create!(name: "First Item")
    menu_item2 = @menu.menu_items.create!(name: "Second Item")

    assert_not menu_item2.update(name: "First Item"), "Should not update to duplicate name"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "uniqueness validation works with spaces and special characters" do
    menu_item1 = @menu.menu_items.create!(name: "Fish & Chips")
    menu_item2 = @menu.menu_items.new(name: "Fish & Chips")

    assert_not menu_item2.save, "Should not save duplicate with special characters"
  end

  test "uniqueness validation works with apostrophes" do
    menu_item1 = @menu.menu_items.create!(name: "O'Reilly Special")
    menu_item2 = @menu.menu_items.new(name: "O'Reilly Special")

    assert_not menu_item2.save, "Should not save duplicate with apostrophes"
  end
end
