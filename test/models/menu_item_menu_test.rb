# test/models/menu_item_menu_test.rb
require "test_helper"

class MenuItemMenuTest < ActiveSupport::TestCase
  def setup
    @menu = create(:menu)
    @menu_item = create(:menu_item)
  end

  test "should create valid menu_item_menu association" do
    association = build(:menu_item_menu, menu: @menu, menu_item: @menu_item)

    assert association.valid?
    assert_difference "MenuItemMenu.count", 1 do
      association.save
    end
  end

  test "should not allow duplicate menu_item_menu associations" do
    create(:menu_item_menu, menu: @menu, menu_item: @menu_item)

    duplicate = build(:menu_item_menu, menu: @menu, menu_item: @menu_item)

    assert_not duplicate.valid?
    assert_includes duplicate.errors.full_messages, "Menu item has already been taken"
  end

  test "should require menu" do
    association = build(:menu_item_menu, menu: nil, menu_item: @menu_item)

    assert_not association.valid?
    assert_includes association.errors.full_messages, "Menu must exist"
  end

  test "should require menu_item" do
    association = build(:menu_item_menu, menu: @menu, menu_item: nil)

    assert_not association.valid?
    assert_includes association.errors.full_messages, "Menu item must exist"
  end

  test "should destroy association when menu is destroyed" do
    association = create(:menu_item_menu, menu: @menu, menu_item: @menu_item)

    assert_difference "MenuItemMenu.count", -1 do
      @menu.destroy
    end
  end

  test "should destroy association when menu_item is destroyed" do
    association = create(:menu_item_menu, menu: @menu, menu_item: @menu_item)

    assert_difference "MenuItemMenu.count", -1 do
      @menu_item.destroy
    end
  end

  test "should allow same menu_item in different menus" do
    menu2 = create(:menu)

    association1 = build(:menu_item_menu, menu: @menu, menu_item: @menu_item)
    association2 = build(:menu_item_menu, menu: menu2, menu_item: @menu_item)

    assert association1.valid?
    assert association2.valid?
  end

  test "should allow different menu_items in same menu" do
    menu_item2 = create(:menu_item)

    association1 = build(:menu_item_menu, menu: @menu, menu_item: @menu_item)
    association2 = build(:menu_item_menu, menu: @menu, menu_item: menu_item2)

    assert association1.valid?
    assert association2.valid?
  end
end
