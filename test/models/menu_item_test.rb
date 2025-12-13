require "test_helper"

class MenuItemTest < ActiveSupport::TestCase
  test "can create, update, and destroy a menu_item with required fields" do
    menu = Menu.create!(name: "Drinks")
    menu_item = MenuItem.new(name: "Coffee", menu: menu)
    assert menu_item.save, "MenuItem should be saved"
    assert menu_item.id.present?, "MenuItem should have an id"
    assert menu_item.price.present?, "MenuItem should have an price"
    assert_equal menu.id, menu_item.menu_id, "MenuItem should have correct menu_id"
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
    menu = Menu.create!(name: "Desserts")
    menu_item = menu.menu_items.create!(name: "Cake")
    assert_equal BigDecimal("0.0"), menu_item.price, "MenuItem should have default price of 0.0"
  end

  test "cannot create menu_item without menu" do
    menu_item = MenuItem.new(name: "Orphan Item")
    assert_not menu_item.save, "MenuItem should not be saved without a menu"
    assert_includes menu_item.errors[:menu], "must exist"
  end

  test "menu_item belongs to menu" do
    menu = Menu.create!(name: "Dinner")
    menu_item = menu.menu_items.create!(name: "Steak")
    assert_equal menu, menu_item.menu
  end
end
