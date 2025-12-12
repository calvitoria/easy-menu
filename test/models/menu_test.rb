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
    menu = Menu.new(name: "Lunch")
    assert_respond_to menu, :menu_items, "Menu should respond to menu_items"
  end
end