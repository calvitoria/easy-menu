require "test_helper"

class MenusControllerTest < ActionDispatch::IntegrationTest
  test "GET /menus returns menus with items" do
    Menu.destroy_all
    MenuItem.destroy_all
  
    menu = Menu.create!(name: "Breakfast")
    menu.menu_items.create!(name: "Coffee", price: 4.0)
    menu.menu_items.create!(name: "Waffles", price: 10.5)
  
    get "/menus"
    assert_response :success
  
    json = JSON.parse(@response.body)
    assert_equal 1, json.length
    assert_equal "Breakfast", json.first["name"]
    assert_equal 2, json.first["menu_items"].length
  end
  
  test "POST /menus creates a menu" do
    post "/menus", params: { menu: { name: "Dinner" } }, as: :json
    assert_response :created

    json = JSON.parse(@response.body)
    assert_equal "Dinner", json["name"]
    assert Menu.exists?(json["id"])
  end

  test "POST /menus fails without name" do
    post "/menus", params: { menu: { name: "" } }, as: :json
    assert_response :unprocessable_entity

    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menus/:id updates a menu" do
    menu = Menu.create!(name: "Original")

    put "/menus/#{menu.id}", params: { menu: { name: "Updated" } }, as: :json
    assert_response :success

    assert_equal "Updated", menu.reload.name
  end

  test "PUT /menus/:id validates name" do
    menu = Menu.create!(name: "Original")

    put "/menus/#{menu.id}", params: { menu: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end
end
