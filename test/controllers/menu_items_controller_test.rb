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
    assert_equal @menu_item.price.to_s, json["price"] # Price is returned as string from JSON
    assert_equal @menu.id, json["menu_id"]
    assert_equal @menu_item.vegan, json["vegan"]
    assert_equal @menu_item.vegetarian, json["vegetarian"]
    assert_equal @menu_item.categories, json["categories"]
    assert_equal @menu_item.description, json["description"]
    assert_equal @menu_item.spicy, json["spicy"]
  end

  test "GET /menu_items/:id returns 404 for non-existent menu item" do
    get "/menu_items/99999"
    assert_response :not_found
  end

  test "POST /menus/:menu_id/menu_items creates a new menu item" do
    assert_difference("MenuItem.count") do
      post "/menus/#{@menu.id}/menu_items", params: { menu_item: { name: "New Item", price: 12.50, vegan: true, vegetarian: false, categories: [ "Appetizer" ], description: "A new delicious item.", spicy: true } }, as: :json
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "New Item", json["name"]
    assert_equal "12.5", json["price"]
    assert_equal true, json["vegan"]
    assert_equal false, json["vegetarian"]
    assert_equal [ "Appetizer" ], json["categories"]
    assert_equal "A new delicious item.", json["description"]
    assert_equal true, json["spicy"]
  end

  test "POST /menus/:menu_id/menu_items fails with invalid params" do
    post "/menus/#{@menu.id}/menu_items", params: { menu_item: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menu_items/:id updates a menu item" do
    put "/menu_items/#{@menu_item.id}", params: { menu_item: { name: "Updated Item", price: 15.00, vegan: false, vegetarian: true, categories: [ "Main Course" ], description: "An updated delicious item.", spicy: false } }, as: :json
    assert_response :success
    @menu_item.reload
    assert_equal "Updated Item", @menu_item.name
    assert_equal 15.00, @menu_item.price
    assert_equal false, @menu_item.vegan
    assert_equal true, @menu_item.vegetarian
    assert_equal [ "Main Course" ], @menu_item.categories
    assert_equal "An updated delicious item.", @menu_item.description
    assert_equal false, @menu_item.spicy
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
