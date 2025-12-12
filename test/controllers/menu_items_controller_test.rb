require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu = Menu.create!(name: "Test Menu")
    @item = @menu.menu_items.create!(name: "Test Item")
  end

  test "GET /menu_items returns all menu items" do
    get "/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    assert json.any? { |item| item["name"] == "Test Item" }
  end

  test "GET /menu_items/:id returns a menu item" do
    get "/menu_items/#{@item.id}"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal @item.name, json["name"]
    assert_equal @menu.id, json["menu_id"]
  end

  test "POST /menu_items creates a menu item" do
    assert_difference "MenuItem.count", 1 do
      post "/menu_items", params: { menu_items: { name: "New Item", menu_id: @menu.id } }, as: :json
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "New Item", json["name"]
    assert_equal @menu.id, json["menu_id"]
  end

  test "POST /menu_items fails with invalid params" do
    post "/menu_items", params: { menu_items: { name: "", menu_id: nil } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Menu must exist"
  end

  test "PUT /menu_items/:id updates a menu item" do
    put "/menu_items/#{@item.id}", params: { menu_items: { name: "Updated Item" } }, as: :json
    assert_response :success
    assert_equal "Updated Item", @item.reload.name
  end

  test "PUT /menu_items/:id fails with invalid params" do
    put "/menu_items/#{@item.id}", params: { menu_items: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "DELETE /menu_items/:id destroys a menu item" do
    assert_difference "MenuItem.count", -1 do
      delete "/menu_items/#{@item.id}"
    end
    assert_response :no_content
  end
end