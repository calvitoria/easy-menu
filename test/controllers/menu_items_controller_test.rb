require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    @menu = create(:menu)
    @menu_item = create(:menu_item, menu: @menu)
  end

  test "GET /menus/:menu_id/menu_items returns menu items for the specific menu" do
    other_menu = create(:menu)
    create(:menu_item, menu: other_menu)

    get "/menus/#{@menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal @menu.menu_items.count, json.length
    assert json.any? { |item| item["id"] == @menu_item.id }
    assert_not json.any? { |item| item["menu_id"] == other_menu.id }
  end

  test "GET /menu_items/:id returns a single menu item" do
    get "/menu_items/#{@menu_item.id}"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal @menu_item.name, json["name"]
    assert_equal @menu.id, json["menu_id"]
  end

  test "GET /menu_items/:id returns 404 for non-existent menu item" do
    get "/menu_items/99999"
    assert_response :not_found
  end

  test "POST /menus/:menu_id/menu_items fails with invalid params" do
    post "/menus/#{@menu.id}/menu_items", params: { menu_item: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menu_items/:id updates a menu item" do
    put "/menu_items/#{@menu_item.id}", params: { menu_item: { name: "Updated Item" } }, as: :json
    assert_response :success
    assert_equal "Updated Item", @menu_item.reload.name
  end

  test "PUT /menu_items/:id fails with invalid params" do
    put "/menu_items/#{@menu_item.id}", params: { menu_item: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "DELETE /menu_items/:id destroys a menu item" do
    assert_difference "MenuItem.count", -1 do
      delete "/menu_items/#{@menu_item.id}"
    end
    assert_response :no_content
    assert_not MenuItem.exists?(@menu_item.id)
  end

  test "DELETE /menu_items/:id returns 404 for non-existent menu item" do
    delete "/menu_items/99999"
    assert_response :not_found
  end
end
