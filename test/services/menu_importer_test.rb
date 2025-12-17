require "test_helper"

class MenuImporterTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "creates menu for restaurant" do
    restaurant = create(:restaurant)
    logger = ImportLogger.new

    MenuImporter.new(logger, restaurant).import([
      { "name" => "Lunch", "menu_items" => [] }
    ])

    assert restaurant.menus.exists?(name: "Lunch")
    assert_equal 1, logger.stats[:menus][:created]
  end

  test "logs error when menus is not an array" do
    restaurant = create(:restaurant)
    logger = ImportLogger.new

    MenuImporter.new(logger, restaurant).import({})

    assert logger.logs.any? { |l| l[:message].include?("valid list of menus") }
    assert_equal 1, logger.stats[:menus][:errors]
  end
end
