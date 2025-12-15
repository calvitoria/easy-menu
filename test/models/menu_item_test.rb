# test/models/menu_item_test.rb
require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
    @menu = create(:menu, restaurant: @restaurant)
    @menu2 = create(:menu, restaurant: @restaurant)
    @menu_item = create(:menu_item)
  end

  test "can create, update, and destroy a menu_item with required fields" do
    menu_item = MenuItem.new(name: "Coffee")
    assert menu_item.save, "MenuItem should be saved"
    assert menu_item.id.present?, "MenuItem should have an id"
    assert menu_item.price.present?, "MenuItem should have an price"
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
    menu_item = MenuItem.create!(name: "Cake")
    assert_equal BigDecimal("0.0"), menu_item.price, "MenuItem should have default price of 0.0"
  end

  test "menu_item belongs to many menus" do
    @menu.menu_items << @menu_item
    @menu2.menu_items << @menu_item

    assert_equal 2, @menu_item.menus.count
    assert_includes @menu_item.menus, @menu
    assert_includes @menu_item.menus, @menu2
  end

  test "cannot create menu_item without a name" do
    menu_item = MenuItem.new
    assert_not menu_item.save, "MenuItem should not be saved without a name"
    assert_includes menu_item.errors[:name], "can't be blank"
  end

  test "categories can be set and retrieved as array" do
    menu_item = MenuItem.create!(name: "Soup", categories: [ "vegan", "starter" ])
    assert_equal [ "vegan", "starter" ], menu_item.categories
  end

  test "categories defaults to empty array" do
    menu_item = MenuItem.create!(name: "Fries")
    assert_equal [], menu_item.categories
  end

  test "menu_item responds to categories as array" do
    menu_item = MenuItem.create!(name: "Wings", categories: [ "spicy" ])
    assert_kind_of Array, menu_item.categories
  end

  test "cannot create menu_item with duplicate name (global uniqueness)" do
    menu_item1 = MenuItem.create!(name: "Burger")
    menu_item2 = MenuItem.new(name: "Burger")

    assert_not menu_item2.save, "MenuItem with duplicate name should not be saved"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "cannot create menu_item with duplicate name case-insensitive" do
    menu_item1 = MenuItem.create!(name: "Burger")
    menu_item2 = MenuItem.new(name: "burger")

    assert_not menu_item2.save, "MenuItem with case-insensitive duplicate name should not be saved"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "can update menu_item to existing name if it's the same record" do
    menu_item = MenuItem.create!(name: "Original Name")
    assert menu_item.update(name: "Original Name"), "Should be able to update with same name"
  end

  test "cannot update menu_item to duplicate name of another item" do
    menu_item1 = MenuItem.create!(name: "First Item")
    menu_item2 = MenuItem.create!(name: "Second Item")

    assert_not menu_item2.update(name: "First Item"), "Should not update to duplicate name"
    assert_includes menu_item2.errors[:name], "has already been taken"
  end

  test "uniqueness validation works with spaces and special characters" do
    menu_item1 = MenuItem.create!(name: "Fish & Chips")
    menu_item2 = MenuItem.new(name: "Fish & Chips")

    assert_not menu_item2.save, "Should not save duplicate with special characters"
  end

  test "uniqueness validation works with apostrophes" do
    menu_item1 = MenuItem.create!(name: "O'Reilly Special")
    menu_item2 = MenuItem.new(name: "O'Reilly Special")

    assert_not menu_item2.save, "Should not save duplicate with apostrophes"
  end

  test "menu_item can belong to multiple menus" do
    @menu.menu_items << @menu_item
    @menu2.menu_items << @menu_item

    assert_equal 2, @menu_item.menus.count
    assert_equal 1, @menu.menu_items.count
    assert_equal 1, @menu2.menu_items.count
  end

  test "destroying menu_item destroys its menu associations but not menus" do
    @menu.menu_items << @menu_item
    @menu2.menu_items << @menu_item

    assert_difference "Menu.count", 0 do
      assert_difference "MenuItemMenu.count", -2 do
        @menu_item.destroy
      end
    end

    assert Menu.exists?(@menu.id)
    assert Menu.exists?(@menu2.id)
  end

  test "menu_item has many menu_item_menus" do
    association = MenuItemMenu.create!(menu: @menu, menu_item: @menu_item)
    assert_includes @menu_item.menu_item_menus, association
  end

  test "menu_item attributes can be set" do
    menu_item = MenuItem.create!(
      name: "Test Item",
      price: 12.99,
      vegan: true,
      vegetarian: true,
      spicy: false,
      description: "A test item",
      categories: [ "Test", "Special" ]
    )

    assert_equal "Test Item", menu_item.name
    assert_equal 12.99, menu_item.price
    assert_equal true, menu_item.vegan
    assert_equal true, menu_item.vegetarian
    assert_equal false, menu_item.spicy
    assert_equal "A test item", menu_item.description
    assert_equal [ "Test", "Special" ], menu_item.categories
  end

  test "menu_item boolean attributes default to false" do
    menu_item = MenuItem.create!(name: "Default Item")

    assert_equal false, menu_item.vegan
    assert_equal false, menu_item.vegetarian
    assert_equal false, menu_item.spicy
  end

  test "menu_item price precision is maintained" do
    menu_item = MenuItem.create!(name: "Precision Test", price: 12.3456)
    assert_equal BigDecimal("12.35"), menu_item.price
  end
end
