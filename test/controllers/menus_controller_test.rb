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

  test "GET /menus/:menu_id/menu_items returns menu items for the menu" do
    menu = Menu.create!(name: "Specials")
    item1 = menu.menu_items.create!(name: "Soup")
    item2 = menu.menu_items.create!(name: "Salad")
    other_menu = Menu.create!(name: "Other")
    other_menu.menu_items.create!(name: "Burger")
  
    get "/menus/#{menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    names = json.map { |item| item["name"] }
    assert_includes names, "Soup"
    assert_includes names, "Salad"
    assert_not_includes names, "Burger"
  end

  test "DELETE /menus/:id destroys a menu and its items" do
    menu = Menu.create!(name: "To Be Deleted")
    menu.menu_items.create!(name: "Item 1")
    menu.menu_items.create!(name: "Item 2")
  
    delete "/menus/#{menu.id}"
  
    assert_response :no_content
    assert_not Menu.exists?(menu.id)
    assert_equal 0, MenuItem.where(menu_id: menu.id).count
  end
end
