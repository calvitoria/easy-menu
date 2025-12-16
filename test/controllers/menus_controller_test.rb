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

  class IndexTest < MenusControllerTest
    test "returns menus with items when nested under restaurant" do
      menu = create(
        :menu,
        name: "Breakfast",
        description: "Morning meals",
        active: true,
        restaurant: @restaurant,
        categories: [ "Breakfast" ]
      )

      coffee = create(:menu_item, name: "Coffee", price: 4.0)
      waffles = create(:menu_item, name: "Waffles", price: 10.5)
      menu.menu_items << coffee
      menu.menu_items << waffles

      get "/restaurants/#{@restaurant.id}/menus"
      assert_response :success

      json = JSON.parse(response.body)
      breakfast_menu = json.find { |m| m["name"] == "Breakfast" }

      assert_not_nil breakfast_menu
      assert_equal "Breakfast", breakfast_menu["name"]
      assert_equal "Morning meals", breakfast_menu["description"]
      assert_equal true, breakfast_menu["active"]
      assert_equal [ "Breakfast" ], breakfast_menu["categories"]
      assert_equal 2, breakfast_menu["menu_items"].length
      assert_equal @restaurant.id, breakfast_menu["restaurant_id"]
    end

    test "returns all menus when not nested" do
      other_restaurant = create(:restaurant)
      other_menu = create(:menu, restaurant: other_restaurant)

      get "/menus"
      assert_response :success

      json = JSON.parse(response.body)
      menu_ids = json.map { |m| m["id"] }

      assert_includes menu_ids, @menu.id
      assert_includes menu_ids, other_menu.id
    end

    test "returns empty array when restaurant has no menus" do
      empty_restaurant = create(:restaurant)

      get "/restaurants/#{empty_restaurant.id}/menus"
      assert_response :success

      json = JSON.parse(response.body)
      assert_equal [], json
    end

    test "returns 404 when restaurant does not exist" do
      get "/restaurants/999999/menus"
      assert_response :not_found
    end

    test "includes correct associations" do
      get "/restaurants/#{@restaurant.id}/menus"
      assert_response :success

      json = JSON.parse(response.body)
      first_menu = json.first

      assert_includes first_menu.keys, "menu_items"
      assert_not_includes first_menu.keys, "restaurant"
    end
  end

  class ShowTest < MenusControllerTest
    test "returns menu with items and restaurant" do
      get "/menus/#{@menu.id}"
      assert_response :success

      json = JSON.parse(response.body)

      assert_equal @menu.name, json["name"]
      assert_equal @menu.description, json["description"]
      assert_equal @menu.active, json["active"]
      assert_equal @menu.categories, json["categories"]
      assert_equal 2, json["menu_items"].length
      assert_equal @restaurant.id, json["restaurant"]["id"]
    end

    test "includes nested restaurant details" do
      get "/menus/#{@menu.id}"
      assert_response :success

      json = JSON.parse(response.body)
      assert_includes json.keys, "restaurant"
      assert_equal @restaurant.name, json["restaurant"]["name"]
    end

    test "returns 404 for non-existent menu" do
      get "/menus/99999"
      assert_response :not_found
    end
  end

  class CreateTest < MenusControllerTest
    test "creates a menu with valid params" do
      assert_difference "Menu.count", 1 do
        post "/restaurants/#{@restaurant.id}/menus", params: {
          menu: {
            name: "Dinner",
            description: "Evening meals",
            active: true,
            categories: [ "Dinner" ]
          }
        }, as: :json
      end

      assert_response :created

      json = JSON.parse(response.body)
      assert_equal "Dinner", json["name"]
      assert_equal "Evening meals", json["description"]
      assert_equal true, json["active"]
      assert_equal [ "Dinner" ], json["categories"]
      assert_equal @restaurant.id, json["restaurant_id"]
      assert Menu.exists?(json["id"])
    end

    test "with categories containing special characters" do
      post "/restaurants/#{@restaurant.id}/menus", params: {
        menu: {
          name: "Special Menu",
          categories: [ "Brunch & Breakfast", "🍔 Burgers", "Spicy 🌶️" ]
        }
      }, as: :json

      assert_response :created
      json = JSON.parse(response.body)
      assert_equal [ "Brunch & Breakfast", "🍔 Burgers", "Spicy 🌶️" ], json["categories"]
    end

    test "allows creating menu with empty categories array" do
      post "/restaurants/#{@restaurant.id}/menus", params: {
        menu: {
          name: "Menu with no categories",
          categories: []
        }
      }, as: :json

      assert_response :created
      json = JSON.parse(response.body)
      assert_equal [], json["categories"]
    end

    test "returns validation errors when name is blank" do
      post "/restaurants/#{@restaurant.id}/menus", params: {
        menu: { name: "", description: "No name" }
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Name can't be blank"
    end

    test "returns validation errors when categories is not an array" do
      post "/restaurants/#{@restaurant.id}/menus", params: {
        menu: {
          name: "Invalid",
          categories: "Dinner"
        }
      }, as: :json

      assert_response :unprocessable_entity

      json = JSON.parse(response.body)
      assert json.key?("error") || json.key?("errors"),
             "Response should contain 'error' or 'errors' key"

      response_text = response.body.downcase
      assert response_text.include?("categor"),
             "Response should mention categories (case-insensitive)"
    end

    test "returns 404 when restaurant does not exist" do
      post "/restaurants/999999/menus", params: {
        menu: { name: "Does not exist" }
      }, as: :json

      assert_response :not_found
    end
  end

  class UpdateTest < MenusControllerTest
    test "updates menu with valid params" do
      menu = create(:menu, name: "Original", active: false, categories: [ "Lunch" ], restaurant: @restaurant)

      put "/menus/#{menu.id}", params: {
        menu: {
          name: "Updated",
          description: "Updated description",
          active: true,
          categories: [ "Dinner" ]
        }
      }, as: :json

      assert_response :success
      menu.reload

      assert_equal "Updated", menu.name
      assert_equal "Updated description", menu.description
      assert_equal true, menu.active
      assert_equal [ "Dinner" ], menu.categories
    end

    test "allows partial update without categories" do
      original_categories = [ "Lunch" ]
      menu = create(:menu, name: "Menu", categories: original_categories, restaurant: @restaurant)

      put "/menus/#{menu.id}", params: {
        menu: { name: "Updated name" }
      }, as: :json

      assert_response :success
      menu.reload

      assert_equal "Updated name", menu.name
      assert_equal original_categories, menu.categories
    end

    test "with empty categories array" do
      put "/menus/#{@menu.id}", params: {
        menu: { categories: [] }
      }, as: :json

      assert_response :success
      @menu.reload
      assert_equal [], @menu.categories
    end

    test "does not allow changing restaurant_id" do
      other_restaurant = create(:restaurant)

      put "/menus/#{@menu.id}", params: {
        menu: { restaurant_id: other_restaurant.id }
      }, as: :json

      assert_response :success
      @menu.reload
      assert_equal @restaurant.id, @menu.restaurant_id
    end

    test "returns validation errors when name is blank" do
      put "/menus/#{@menu.id}", params: {
        menu: { name: "" }
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Name can't be blank"
    end

    test "returns validation errors when categories is not an array" do
      put "/menus/#{@menu.id}", params: {
        menu: { categories: "Invalid" }
      }, as: :json

      assert_response :unprocessable_entity

      json = JSON.parse(response.body)
      assert json.key?("error") || json.key?("errors"),
             "Response should contain 'error' or 'errors' key"

      response_text = response.body.downcase
      assert response_text.include?("categor"),
             "Response should mention categories (case-insensitive)"
    end

    test "returns 404 when menu does not exist" do
      put "/menus/99999", params: {
        menu: { name: "Does not exist" }
      }, as: :json

      assert_response :not_found
    end
  end

  class DestroyTest < MenusControllerTest
    test "destroys menu and removes associations" do
      menu = create(:menu, name: "To Be Deleted", restaurant: @restaurant)
      item1 = create(:menu_item)
      item2 = create(:menu_item)
      menu.menu_items << item1
      menu.menu_items << item2

      assert_difference "Menu.count", -1 do
        delete "/menus/#{menu.id}"
      end

      assert_response :no_content
      assert_not Menu.exists?(menu.id)

      assert MenuItem.exists?(item1.id)
      assert MenuItem.exists?(item2.id)
      assert_empty item1.reload.menus
      assert_empty item2.reload.menus
    end

    test "returns 404 when menu does not exist" do
      delete "/menus/99999"
      assert_response :not_found
    end
  end

  class AddMenuItemTest < MenusControllerTest
    test "adds menu item to menu" do
      new_item = create(:menu_item, name: "New Item")

      assert_difference "@menu.menu_items.count", 1 do
        post "/menus/#{@menu.id}/add_menu_item", params: {
          menu_item_id: new_item.id
        }, as: :json
      end

      assert_response :success
      json = JSON.parse(response.body)

      assert_equal "Menu item added successfully", json["message"]
      assert_equal @menu.id, json["menu"]["id"]
      assert_equal new_item.id, json["menu_item"]["id"]
    end

    test "returns error when menu item is already in menu" do
      post "/menus/#{@menu.id}/add_menu_item", params: {
        menu_item_id: @menu_item.id
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Menu item already exists in menu"
    end

    test "returns 404 when menu item does not exist" do
      post "/menus/#{@menu.id}/add_menu_item", params: {
        menu_item_id: 99999
      }, as: :json

      assert_response :not_found
    end

    test "returns 404 when menu does not exist" do
      post "/menus/99999/add_menu_item", params: {
        menu_item_id: @menu_item.id
      }, as: :json

      assert_response :not_found
    end
  end

  class RemoveMenuItemTest < MenusControllerTest
    test "removes menu item from menu" do
      assert_difference "@menu.menu_items.count", -1 do
        delete "/menus/#{@menu.id}/remove_menu_item", params: {
          menu_item_id: @menu_item.id
        }, as: :json
      end

      assert_response :success
      json = JSON.parse(response.body)

      assert_equal "Menu item removed successfully", json["message"]
      assert_equal @menu.id, json["menu"]["id"]
    end

    test "returns error when menu item is not in menu" do
      unassociated_item = create(:menu_item)

      delete "/menus/#{@menu.id}/remove_menu_item", params: {
        menu_item_id: unassociated_item.id
      }, as: :json

      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Could not remove menu item from menu"
    end

    test "returns 404 when menu item does not exist" do
      delete "/menus/#{@menu.id}/remove_menu_item", params: {
        menu_item_id: 99999
      }, as: :json

      assert_response :not_found
    end

    test "returns 404 when menu does not exist" do
      delete "/menus/99999/remove_menu_item", params: {
        menu_item_id: @menu_item.id
      }, as: :json

      assert_response :not_found
    end
  end

  class MenuItemsIndexTest < MenusControllerTest
    test "returns menu items for the menu" do
      menu = create(:menu, restaurant: @restaurant)
      soup = create(:menu_item, name: "Soup")
      salad = create(:menu_item, name: "Salad")
      menu.menu_items << soup
      menu.menu_items << salad

      get "/menus/#{menu.id}/menu_items"
      assert_response :success

      json = JSON.parse(response.body)
      names = json.map { |item| item["name"] }

      assert_includes names, "Soup"
      assert_includes names, "Salad"
      assert_equal 2, names.length
    end

    test "returns empty array when menu has no items" do
      empty_menu = create(:menu, restaurant: @restaurant)

      get "/menus/#{empty_menu.id}/menu_items"
      assert_response :success

      json = JSON.parse(response.body)
      assert_equal [], json
    end
  end
end
