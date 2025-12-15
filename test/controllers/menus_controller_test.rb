require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
    @menu = create(:menu, restaurant: @restaurant)
    @menu_item = create(:menu_item)
    @menu_item2 = create(:menu_item)

    @menu.menu_items << @menu_item
    @menu.menu_items << @menu_item2
  end

  test "GET restaurants/:id/menus returns menus with items" do
    menu = create(
      :menu,
      name: "Breakfast",
      description: "Morning meals",
      active: true,
      restaurant_id: @restaurant.id,
      categories: [ "Breakfast" ]
    )

    coffee = create(:menu_item, name: "Coffee", price: 4.0)
    waffles = create(:menu_item, name: "Waffles", price: 10.5)

    menu.menu_items << coffee
    menu.menu_items << waffles

    get "/restaurants/#{@restaurant.id}/menus"
    assert_response :success

    json = JSON.parse(@response.body)

    breakfast_menu = json.find { |m| m["name"] == "Breakfast" }

    assert_not_nil breakfast_menu
    assert_equal "Breakfast", breakfast_menu["name"]
    assert_equal "Morning meals", breakfast_menu["description"]
    assert_equal true, breakfast_menu["active"]
    assert_equal [ "Breakfast" ], breakfast_menu["categories"]
    assert_equal 2, breakfast_menu["menu_items"].length
  end

  test "POST restaurants/:id/menus creates a menu" do
    post "/restaurants/#{@restaurant.id}/menus", params:
    { menu: { name: "Dinner", description: "Evening meals", active: true, restaurant_id: @restaurant.id, categories: [ "Dinner" ] } }, as: :json
    assert_response :created

    json = JSON.parse(@response.body)
    assert_equal "Dinner", json["name"]
    assert_equal "Evening meals", json["description"]
    assert_equal true, json["active"]
    assert_equal [ "Dinner" ], json["categories"]
    assert_equal @restaurant.id, json["restaurant_id"]
    assert Menu.exists?(json["id"])
  end

  test "POST restaurants/:id/menus fails without name" do
    post "/restaurants/#{@restaurant.id}/menus", params: { menu: { name: "", restaurant_id: @restaurant.id } }, as: :json
    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "POST restaurants/:id/menus rejects non-array categories" do
    post "/restaurants/#{@restaurant.id}/menus", params: {
      menu: {
        name: "Invalid",
        restaurant_id: @restaurant.id,
        categories: "Dinner"
      }
    }, as: :json

    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "categories must be an array of strings"
  end

  test "POST restaurants/:id/menus returns 404 when restaurant does not exist" do
    put "/restaurants/999999/menus", params: {
      menu: {
        name: "Does not exist",
        restaurant_id: @restaurant.id
      }
    }, as: :json

    assert_response :not_found
  end

  test "PUT /menus/:id updates a menu" do
    menu = create(
      :menu, name: "Original", description: "Original description", active: false, categories: [ "Lunch" ], restaurant: @restaurant)

    put "/menus/#{menu.id}", params: { menu: { name: "Updated", description: "Updated description", active: true, categories: [ "Dinner" ], restaurant_id: @restaurant.id } }, as: :json
    assert_response :success

    menu.reload
    assert_equal "Updated", menu.name
    assert_equal "Updated description", menu.description
    assert_equal true, menu.active
    assert_equal [ "Dinner" ], menu.categories
    assert_equal @restaurant.id, menu.restaurant_id
  end

  test "PUT /menus/:id validates name" do
    menu = create(:menu, name: "Original", restaurant: @restaurant)

    put "/menus/#{menu.id}", params: { menu: { name: "", restaurant_id: @restaurant.id } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menus/:id rejects non-array categories" do
    menu = create(:menu, name: "Menu", restaurant: @restaurant)

    put "/menus/#{menu.id}", params: {
      menu: {
        categories: "Invalid",
        restaurant_id: @restaurant.id
      }
    }, as: :json

    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_includes json["errors"], "categories must be an array of strings"
  end

  test "PUT /menus/:id allows update without categories" do
    menu = create(:menu, name: "Menu", categories: [ "Lunch" ], restaurant: @restaurant)

    put "/menus/#{menu.id}", params: {
      menu: {
        name: "Updated name",
        restaurant_id: @restaurant.id
      }
    }, as: :json

    assert_response :success

    menu.reload
    assert_equal "Updated name", menu.name
    assert_equal [ "Lunch" ], menu.categories
    assert_equal @restaurant.id, menu.restaurant_id
  end

  test "PUT /menus/:id returns 404 when menu does not exist" do
    put "/menus/99999", params: {
      menu: {
        name: "Does not exist",
        restaurant_id: @restaurant.id
      }
    }, as: :json

    assert_response :not_found
  end

  test "GET /menus/:menu_id/menu_items returns menu items for the menu" do
    menu = create(:menu, name: "Specials", restaurant: @restaurant)
    soup = create(:menu_item, name: "Soup")
    salad = create(:menu_item, name: "Salad")

    menu.menu_items << soup
    menu.menu_items << salad

    other_menu = create(:menu, name: "Other", restaurant: @restaurant)
    burger = create(:menu_item, name: "Burger")
    other_menu.menu_items << burger

    get "/menus/#{menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    names = json.map { |item| item["name"] }
    assert_includes names, "Soup"
    assert_includes names, "Salad"
    assert_not_includes names, "Burger"
  end

  test "DELETE /menus/:id destroys a menu and its associations" do
    menu = create(:menu, name: "To Be Deleted", restaurant: @restaurant)
    item1 = create(:menu_item, name: "Item 1")
    item2 = create(:menu_item, name: "Item 2")

    menu.menu_items << item1
    menu.menu_items << item2

    delete "/menus/#{menu.id}"

    assert_response :no_content
    assert_not Menu.exists?(menu.id)

    assert MenuItem.exists?(item1.id)
    assert MenuItem.exists?(item2.id)

    assert_empty item1.reload.menus
    assert_empty item2.reload.menus
  end

  test "GET /menus/:id returns a single menu with items" do
    menu = create(:menu, name: "Lunch", description: "Midday meals", active: true, categories: [ "Lunch" ], restaurant: @restaurant)
    sandwich = create(:menu_item, name: "Sandwich", price: 8.0)
    salad = create(:menu_item, name: "Salad", price: 7.5)

    menu.menu_items << sandwich
    menu.menu_items << salad

    get "/menus/#{menu.id}"
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal "Lunch", json["name"]
    assert_equal "Midday meals", json["description"]
    assert_equal true, json["active"]
    assert_equal [ "Lunch" ], json["categories"]
    assert_equal 2, json["menu_items"].length
    assert_equal menu.id, json["id"]
  end

  test "GET restaurants/:id/menus returns empty array when no menus exist" do
    @menu.destroy

    get "/restaurants/#{@restaurant.id}/menus"
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal [], json
  end

  test "GET /menus/:id returns 404 for non-existent menu" do
    get "/menus/99999"
    assert_response :not_found
  end

  test "POST /menus/:id/add_menu_item associates item with menu" do
    new_item = create(:menu_item, name: "New Item")

    assert_difference "@menu.menu_items.count", 1 do
      post "/menus/#{@menu.id}/add_menu_item", params: { menu_item_id: new_item.id }, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Menu item added successfully", json["message"]
  end

  test "POST /menus/:id/add_menu_item returns error for duplicate association" do
    post "/menus/#{@menu.id}/add_menu_item", params: { menu_item_id: @menu_item.id }, as: :json

    assert_response :unprocessable_entity
  end

  test "DELETE /menus/:id/remove_menu_item removes association" do
    assert_difference "@menu.menu_items.count", -1 do
      delete "/menus/#{@menu.id}/remove_menu_item", params: { menu_item_id: @menu_item.id }, as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Menu item removed successfully", json["message"]

    assert MenuItem.exists?(@menu_item.id)
  end

  test "DELETE /menus/:id/remove_menu_item returns error for non-existent item" do
    delete "/menus/#{@menu.id}/remove_menu_item", params: { menu_item_id: 99999 }, as: :json

    assert_response :not_found
  end
end
