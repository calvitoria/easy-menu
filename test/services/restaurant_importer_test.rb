require "test_helper"

class RestaurantImporterTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "creates restaurant when it does not exist" do
    logger = ImportLogger.new

    data = [ { "name" => "New Place", "menus" => [] } ]

    RestaurantImporter.new(logger).import(data)

    assert Restaurant.exists?(name: "New Place")
    assert_equal 1, logger.stats[:restaurants][:created]
  end

  test "logs error when restaurant name is missing" do
    logger = ImportLogger.new

    RestaurantImporter.new(logger).import([ { "menus" => [] } ])

    assert logger.logs.any? { |l| l[:level] == "ERROR" }
    assert_equal 1, logger.stats[:restaurants][:errors]
  end

  test "reuses existing restaurant" do
    create(:restaurant, name: "Poppo")

    logger = ImportLogger.new
    RestaurantImporter.new(logger).import([ { "name" => "Poppo", "menus" => [] } ])

    assert_equal 1, Restaurant.count
    assert_equal 1, logger.stats[:restaurants][:updated]
  end
end
