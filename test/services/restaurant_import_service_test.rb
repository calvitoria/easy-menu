require "test_helper"

class RestaurantImportServiceTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    file_path = Rails.root.join("restaurant_data.json")
    @json_data = JSON.parse(File.read(file_path))
  end

  test "imports restaurants and menus successfully" do
    result = RestaurantImportService.new(@json_data).import

    assert result[:success]
    assert_equal 2, Restaurant.count
    assert_equal 4, Menu.count
  end

  test "imports menu items only from menu_items key" do
    RestaurantImportService.new(@json_data).import

    assert_equal 3, MenuItem.count
    assert MenuItem.exists?(name: "Burger")
    assert MenuItem.exists?(name: "Small Salad")
    assert MenuItem.exists?(name: "Large Salad")

    assert_not MenuItem.exists?(name: "Chicken Wings")
    assert_not MenuItem.exists?(name: "Mega \"Burger\"")
  end

  test "reuses menu items by name across different menus" do
    RestaurantImportService.new(@json_data).import

    burger = MenuItem.find_by(name: "Burger")
    assert_not_nil burger

    restaurant = Restaurant.find_by(name: "Poppo's Cafe")
    lunch_menu = restaurant.menus.find_by(name: "lunch")
    dinner_menu = restaurant.menus.find_by(name: "dinner")

    assert_includes lunch_menu.menu_items, burger
    assert_includes dinner_menu.menu_items, burger
  end

  test "last processed price wins when menu item appears multiple times" do
    RestaurantImportService.new(@json_data).import

    burger = MenuItem.find_by(name: "Burger")
    assert_equal 15.0, burger.price.to_f
  end

  test "does not create duplicate menu_item associations" do
    RestaurantImportService.new(@json_data).import
    RestaurantImportService.new(@json_data).import

    burger = MenuItem.find_by(name: "Burger")
    menu = Menu.find_by(
      name: "lunch",
      restaurant: Restaurant.find_by(name: "Poppo's Cafe")
    )

    assert_equal 1, MenuItemMenu.where(menu: menu, menu_item: burger).count
  end

  test "increments menu errors counter for invalid menus" do
    result = RestaurantImportService.new(@json_data).import
    stats = result[:stats]

    assert stats[:menus][:errors] > 0
  end

  test "logs errors but does not fail the entire import" do
    bad_data = { "restaurants" => [ { "name" => nil } ] }

    result = RestaurantImportService.new(bad_data).import

    assert result[:success]
    assert result[:logs].any? { |l| l[:level] == "ERROR" }
  end

  test "returns duration and summary" do
    result = RestaurantImportService.new(@json_data).import

    assert result[:duration].is_a?(Numeric)
    assert_match(/Processed \d+ records with \d+ errors/, result[:summary])
  end

  test "logs error when restaurants is not an array" do
    result = RestaurantImportService.new({ "restaurants" => {} }).import

    assert result[:success]
    assert result[:logs].any? { |l|
      l[:message].include?("list of restaurants")
    }
  end

  test "handles empty restaurants array gracefully" do
    result = RestaurantImportService.new({ "restaurants" => [] }).import

    assert result[:success]
    assert_equal 0, Restaurant.count
  end

  test "reuses existing restaurant by name" do
    create(:restaurant, name: "Poppo's Cafe")

    RestaurantImportService.new(@json_data).import

    assert_equal 2, Restaurant.count
  end

  test "does not create duplicate menus for same restaurant" do
    RestaurantImportService.new(@json_data).import
    RestaurantImportService.new(@json_data).import

    restaurant = Restaurant.find_by(name: "Poppo's Cafe")
    assert_equal 2, restaurant.menus.count
  end

  test "logs unknown restaurant attributes as errors" do
    data = {
      "restaurants" => [
        { "name" => "Test", "foo" => "bar" }
      ]
    }

    result = RestaurantImportService.new(data).import

    assert result[:logs].any? { |l|
      l[:message].include?("unsupported field") &&
      l[:message].include?("foo")
    }
  end

  test "logs error when file path does not exist" do
    result = RestaurantImportService.new(nil, "missing.json").import

    assert result[:logs].any? { |l|
      l[:message].include?("could not be found")
    }
  end

  test "includes info logs for successful operations" do
    result = RestaurantImportService.new(@json_data).import

    info_logs = result[:logs].select { |l| l[:level] == "INFO" }

    assert info_logs.any?
    assert info_logs.any? { |l| l[:message].include?("Restaurant") }
    assert info_logs.any? { |l| l[:message].include?("Menu") }
  end
end
