# test/models/menu_test.rb
require "test_helper"

class MenuTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
    @menu = create(:menu, restaurant: @restaurant)
    @menu_item = create(:menu_item)
    @menu_item2 = create(:menu_item)
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

  test "menu has many menu_items through menu_item_menus" do
    @menu.menu_items << @menu_item
    @menu.menu_items << @menu_item2

    assert_equal 2, @menu.menu_items.count
    assert_includes @menu.menu_items, @menu_item
    assert_includes @menu.menu_items, @menu_item2
  end

  test "destroying menu destroys its menu_item associations but not menu_items" do
    @menu.menu_items << @menu_item
    @menu.menu_items << @menu_item2

    assert_difference "MenuItem.count", 0 do
      assert_difference "MenuItemMenu.count", -2 do
        @menu.destroy
      end
    end

    assert MenuItem.exists?(@menu_item.id)
    assert MenuItem.exists?(@menu_item2.id)
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

  test "menu can have multiple menu items" do
    @menu.menu_items << @menu_item
    @menu.menu_items << @menu_item2

    assert_equal 2, @menu.menu_items.count
  end

  test "same menu item can belong to multiple menus" do
    menu2 = create(:menu, restaurant: @restaurant)

    @menu.menu_items << @menu_item
    menu2.menu_items << @menu_item

    assert_equal 1, @menu.menu_items.count
    assert_equal 1, menu2.menu_items.count
    assert_equal 2, @menu_item.menus.count
  end

  test "menu has many menu_item_menus" do
    association = MenuItemMenu.create!(menu: @menu, menu_item: @menu_item)
    assert_includes @menu.menu_item_menus, association
  end

  test "menu items are destroyed when menu is destroyed" do
    @menu.menu_items << @menu_item
    @menu.menu_items << @menu_item2

    menu_id = @menu.id
    @menu.destroy

    assert_empty MenuItemMenu.where(menu_id: menu_id)
  end
end
