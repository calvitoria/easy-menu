require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "can create, update, and destroy a menu with required fields" do
    menu = Menu.new(name: "Breakfast")
    assert menu.save, "Menu should be saved"
    assert menu.id.present?, "Menu should have an id"
    assert_equal "Breakfast", menu.name
    assert menu.created_at.present?, "Menu should have created_at"
    assert menu.updated_at.present?, "Menu should have updated_at"

    menu.update(name: "Brunch")
    assert_equal "Brunch", menu.reload.name

    menu_id = menu.id
    assert menu.destroy, "Menu should be destroyed"
    assert_nil Menu.find_by(id: menu_id), "Menu should not exist after destroy"
  end

  test "menu has many menu_items" do
    menu = Menu.create!(name: "Lunch")
    item1 = menu.menu_items.create!(name: "Burger")
    item2 = menu.menu_items.create!(name: "Fries")
    assert_equal 2, menu.menu_items.count
    assert_includes menu.menu_items, item1
    assert_includes menu.menu_items, item2
  end

  test "destroying menu destroys its menu_items" do
    menu = Menu.create!(name: "Snacks")
    menu_item = menu.menu_items.create!(name: "Chips")
    menu.destroy
    assert_nil MenuItem.find_by(id: menu_item.id), "MenuItem should be destroyed when menu is destroyed"
  end
end
