require "test_helper"

class MenuItemImporterTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "creates menu item and associates it to menu" do
    menu = create(:menu)
    logger = ImportLogger.new

    MenuItemImporter.new(logger, menu).import([
      { "name" => "Burger", "price" => 10 }
    ])

    item = MenuItem.find_by(name: "Burger")
    assert_not_nil item
    assert_includes menu.menu_items, item
  end

  test "reuses menu item by name and updates price" do
    item = create(:menu_item, name: "Burger", price: 5)
    menu = create(:menu)
    logger = ImportLogger.new

    MenuItemImporter.new(logger, menu).import([
      { "name" => "Burger", "price" => 15 }
    ])

    assert_equal 15, item.reload.price
  end

  test "logs error when name is missing" do
    menu = create(:menu)
    logger = ImportLogger.new

    MenuItemImporter.new(logger, menu).import([ {} ])

    assert logger.logs.any? { |l| l[:message].include?("missing name") }
    assert_equal 1, logger.stats[:menu_items][:errors]
  end
end
