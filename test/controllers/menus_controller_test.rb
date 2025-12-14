require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    MenuItem.destroy_all
    Menu.destroy_all
  end

  test "GET /menus returns menus with items" do
    menu = create(:menu, name: "Breakfast", description: "Morning meals", active: true, categories: [ "Breakfast" ])
    create(:menu_item, menu: menu, name: "Coffee", price: 4.0)
    create(:menu_item, menu: menu, name: "Waffles", price: 10.5)

    get "/menus"
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal 1, json.length
    assert_equal "Breakfast", json.first["name"]
    assert_equal "Morning meals", json.first["description"]
    assert_equal true, json.first["active"]
    assert_equal [ "Breakfast" ], json.first["categories"]
    assert_equal 2, json.first["menu_items"].length
  end

  test "POST /menus creates a menu" do
    post "/menus", params: { menu: { name: "Dinner", description: "Evening meals", active: true, categories: [ "Dinner" ] } }, as: :json
    assert_response :created

    json = JSON.parse(@response.body)
    assert_equal "Dinner", json["name"]
    assert_equal "Evening meals", json["description"]
    assert_equal true, json["active"]
    assert_equal [ "Dinner" ], json["categories"]
    assert Menu.exists?(json["id"])
  end

  test "POST /menus fails without name" do
    post "/menus", params: { menu: { name: "" } }, as: :json
    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "POST /menus rejects non-array categories" do
    post "/menus", params: {
      menu: {
        name: "Invalid",
        categories: "Dinner"
      }
    }, as: :json

    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "categories must be an array of strings"
  end

  test "PUT /menus/:id updates a menu" do
    menu = create(:menu, name: "Original", description: "Original description", active: false, categories: [ "Lunch" ])

    put "/menus/#{menu.id}", params: { menu: { name: "Updated", description: "Updated description", active: true, categories: [ "Dinner" ] } }, as: :json
    assert_response :success

    menu.reload
    assert_equal "Updated", menu.name
    assert_equal "Updated description", menu.description
    assert_equal true, menu.active
    assert_equal [ "Dinner" ], menu.categories
  end

  test "PUT /menus/:id validates name" do
    menu = create(:menu, name: "Original")

    put "/menus/#{menu.id}", params: { menu: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menus/:id rejects non-array categories" do
    menu = create(:menu, name: "Menu")

    put "/menus/#{menu.id}", params: {
      menu: {
        categories: "Invalid"
      }
    }, as: :json

    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "categories must be an array of strings"
  end

  test "PUT /menus/:id allows update without categories" do
    menu = create(:menu, name: "Menu", categories: [ "Lunch" ])

    put "/menus/#{menu.id}", params: {
      menu: {
        name: "Updated name"
      }
    }, as: :json

    assert_response :success

    menu.reload
    assert_equal "Updated name", menu.name
    assert_equal [ "Lunch" ], menu.categories
  end

  test "PUT /menus/:id returns 404 when menu does not exist" do
    put "/menus/99999", params: {
      menu: {
        name: "Does not exist"
      }
    }, as: :json

    assert_response :not_found
  end

  test "GET /menus/:menu_id/menu_items returns menu items for the menu" do
    menu = create(:menu, name: "Specials")
    create(:menu_item, menu: menu, name: "Soup")
    create(:menu_item, menu: menu, name: "Salad")
    other_menu = create(:menu, name: "Other")
    create(:menu_item, menu: other_menu, name: "Burger")

    get "/menus/#{menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    names = json.map { |item| item["name"] }
    assert_includes names, "Soup"
    assert_includes names, "Salad"
    assert_not_includes names, "Burger"
  end

  test "DELETE /menus/:id destroys a menu and its items" do
    menu = create(:menu, name: "To Be Deleted")
    create(:menu_item, menu: menu, name: "Item 1")
    create(:menu_item, menu: menu, name: "Item 2")

    delete "/menus/#{menu.id}"

    assert_response :no_content
    assert_not Menu.exists?(menu.id)
    assert_equal 0, MenuItem.where(menu_id: menu.id).count
  end

  test "GET /menus/:id returns a single menu with items" do
    menu = create(:menu, name: "Lunch", description: "Midday meals", active: true, categories: [ "Lunch" ])
    create(:menu_item, menu: menu, name: "Sandwich", price: 8.0)
    create(:menu_item, menu: menu, name: "Salad", price: 7.5)

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

  test "GET /menus returns empty array when no menus exist" do
    get "/menus"
    assert_response :success

    json = JSON.parse(@response.body)
    assert_equal [], json
  end

  test "GET /menus/:id returns 404 for non-existent menu" do
    get "/menus/99999"
    assert_response :not_found
  end
end
