require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
    @menu = create(:menu, restaurant: @restaurant)
    @menu2 = create(:menu, restaurant: @restaurant)
    @menu_item = create(:menu_item)

    @menu.menu_items << @menu_item
    @menu2.menu_items << @menu_item
  end

  # JSON API Tests
  class ApiTest < MenuItemsControllerTest
    class IndexTest < ApiTest
      test "returns menu items for the specific menu when nested" do
        other_menu = create(:menu, restaurant: @restaurant)
        other_item = create(:menu_item)
        other_menu.menu_items << other_item

        get "/menus/#{@menu.id}/menu_items.json"
        assert_response :success
        json = JSON.parse(response.body)

        assert_equal 1, json.length
        assert_equal @menu_item.id, json[0]["id"]
        assert_equal @menu_item.name, json[0]["name"]
        assert_includes json[0].keys, "menus"
      end

      test "returns empty array when menu has no items" do
        empty_menu = create(:menu, restaurant: @restaurant)
        get "/menus/#{empty_menu.id}/menu_items.json"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal [], json
      end

      test "returns all menu items with menus when not nested" do
        item2 = create(:menu_item)
        item3 = create(:menu_item)

        @menu.menu_items << item2
        @menu2.menu_items << item3

        get "/menu_items.json"
        assert_response :success
        json = JSON.parse(response.body)

        assert json.length >= 3
        json.each do |item|
          assert item.key?("menus")
          assert_kind_of Array, item["menus"]
        end
      end
    end

    class ShowTest < ApiTest
      test "returns a single menu item with menus" do
        get "/menu_items/#{@menu_item.id}.json"
        assert_response :success
        json = JSON.parse(response.body)

        assert_equal @menu_item.name, json["name"]
        assert_equal @menu_item.price.to_s, json["price"]
        assert_equal @menu_item.vegan, json["vegan"]
        assert_equal @menu_item.vegetarian, json["vegetarian"]
        assert_equal @menu_item.categories, json["categories"]
        assert_equal @menu_item.description, json["description"]
        assert_equal @menu_item.spicy, json["spicy"]

        assert json.key?("menus")
        assert_equal 2, json["menus"].length
        menu_ids = json["menus"].map { |m| m["id"] }
        assert_includes menu_ids, @menu.id
        assert_includes menu_ids, @menu2.id
      end

      test "menu item can be associated with multiple menus" do
        menu3 = create(:menu, restaurant: @restaurant)
        @menu_item.menus << menu3

        get "/menu_items/#{@menu_item.id}.json"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 3, json["menus"].length
      end

      test "returns 404 for non-existent menu item" do
        get "/menu_items/99999.json"
        assert_response :not_found
      end
    end

    class CreateTest < ApiTest
      test "creates a new menu item and associates with menu when nested" do
        assert_difference("MenuItem.count") do
          assert_difference("MenuItemMenu.count", 1) do
            post "/menus/#{@menu.id}/menu_items.json", params: {
              menu_item: {
                name: "New Item",
                price: 12.50,
                vegan: true,
                vegetarian: false,
                categories: [ "Appetizer" ],
                description: "A new delicious item.",
                spicy: true
              }
            }, as: :json
          end
        end
        assert_response :created
        json = JSON.parse(response.body)

        assert_equal "New Item", json["name"]
        assert_equal "12.5", json["price"]
        assert_equal true, json["vegan"]
        assert_equal false, json["vegetarian"]
        assert_equal [ "Appetizer" ], json["categories"]
        assert_equal "A new delicious item.", json["description"]
        assert_equal true, json["spicy"]
        assert_equal 1, json["menus"].length
        assert_equal @menu.id, json["menus"][0]["id"]
      end

      test "creates a new menu item with multiple menu associations" do
        assert_difference("MenuItem.count") do
          assert_difference("MenuItemMenu.count", 2) do
            post "/menu_items.json", params: {
              menu_item: {
                name: "Global Item",
                price: 15.99,
                description: "Item in multiple menus"
              },
              menu_ids: [ @menu.id, @menu2.id ]
            }, as: :json
          end
        end
        assert_response :created
        json = JSON.parse(response.body)

        assert_equal "Global Item", json["name"]
        assert_equal 2, json["menus"].length
        menu_ids = json["menus"].map { |m| m["id"] }
        assert_includes menu_ids, @menu.id
        assert_includes menu_ids, @menu2.id
      end

      test "creates a menu item without menu associations" do
        assert_difference("MenuItem.count") do
          assert_no_difference("MenuItemMenu.count") do
            post "/menu_items.json", params: {
              menu_item: {
                name: "Standalone Item",
                price: 8.99
              }
            }, as: :json
          end
        end
        assert_response :created
        json = JSON.parse(response.body)

        assert_equal "Standalone Item", json["name"]
        assert_empty json["menus"]
      end

      test "fails with duplicate name" do
        create(:menu_item, name: "Unique Item")

        assert_no_difference("MenuItem.count") do
          post "/menu_items.json", params: {
            menu_item: {
              name: "Unique Item",
              price: 12.99
            }
          }, as: :json
        end

        assert_response :unprocessable_entity
        json = JSON.parse(response.body)
        assert_includes json["errors"], "Name has already been taken"
      end

      test "fails with invalid params" do
        post "/menus/#{@menu.id}/menu_items.json", params: { menu_item: { name: "" } }, as: :json
        assert_response :unprocessable_entity
        json = JSON.parse(response.body)
        assert_includes json["errors"], "Name can't be blank"
      end
    end

    class UpdateTest < ApiTest
      test "updates a menu item" do
        put "/menu_items/#{@menu_item.id}.json", params: {
          menu_item: {
            name: "Updated Item",
            price: 15.00,
            vegan: false,
            vegetarian: true,
            categories: [ "Main Course" ],
            description: "An updated delicious item.",
            spicy: false
          }
        }, as: :json
        assert_response :success

        @menu_item.reload
        assert_equal "Updated Item", @menu_item.name
        assert_equal 15.00, @menu_item.price
        assert_equal false, @menu_item.vegan
        assert_equal true, @menu_item.vegetarian
        assert_equal [ "Main Course" ], @menu_item.categories
        assert_equal "An updated delicious item.", @menu_item.description
        assert_equal false, @menu_item.spicy
        assert_equal 2, @menu_item.menus.count
      end

      test "updates menu associations with menu_ids" do
        menu3 = create(:menu, restaurant: @restaurant)

        put "/menu_items/#{@menu_item.id}.json", params: {
          menu_item: {
            price: 18.99
          },
          menu_ids: [ menu3.id ]
        }, as: :json
        assert_response :success

        @menu_item.reload
        assert_equal 18.99, @menu_item.price
        assert_equal 1, @menu_item.menus.count
        assert_equal menu3.id, @menu_item.menus.first.id
      end
    end

    class DestroyTest < ApiTest
      test "destroys a menu item and its associations" do
        assert_difference "MenuItem.count", -1 do
          assert_difference "MenuItemMenu.count", -2 do
            delete "/menu_items/#{@menu_item.id}.json"
          end
        end
        assert_response :no_content
        assert_not MenuItem.exists?(@menu_item.id)

        assert Menu.exists?(@menu.id)
        assert Menu.exists?(@menu2.id)
      end
    end
  end

  # HTML Interface Tests
  class HtmlInterfaceTest < MenuItemsControllerTest
    test "gets index" do
      get menu_items_url
      assert_response :success
      assert_select "h1", "Menu Items"
    end

    test "gets index for a menu" do
      get menu_menu_items_url(@menu)
      assert_response :success
      assert_select "h1", "Menu Items for #{@menu.name}"
    end

    test "gets new" do
      get new_menu_item_url
      assert_response :success
      assert_select "h2", "Add New Menu Item"
    end

    test "gets new for a menu" do
      get new_menu_menu_item_url(@menu)
      assert_response :success
      assert_select "h2", "Add New Menu Item to #{@menu.name}"
    end

    test "gets edit" do
      get edit_menu_item_url(@menu_item)
      assert_response :success
      assert_select "h2", "Edit #{@menu_item.name}"
    end

    test "gets show" do
      get menu_item_url(@menu_item)
      assert_response :success
      assert_select "h1", @menu_item.name
    end

    test "creates menu item" do
      assert_difference("MenuItem.count") do
        post menu_items_url, params: { menu_item: { name: "New Sandwich", price: 9.99 } }
      end

      assert_redirected_to menu_item_url(MenuItem.last)
      follow_redirect!
      assert_select "p", text: "Menu item was successfully created."
    end

    test "creates menu item for a menu" do
        assert_difference("MenuItem.count") do
            post menu_menu_items_url(@menu), params: { menu_item: { name: "New Soup", price: 5.99 } }
        end

        new_item = MenuItem.last
        assert_redirected_to menu_item_url(new_item)
        assert_includes new_item.menus, @menu
    end

    test "fails to create menu item with invalid data" do
      assert_no_difference("MenuItem.count") do
        post menu_items_url, params: { menu_item: { name: "" } }
      end

      assert_response :unprocessable_entity
      assert_select ".text-red-800", /prohibited this menu item from being saved/
    end

    test "updates menu item" do
      patch menu_item_url(@menu_item), params: { menu_item: { name: "Updated Sandwich" } }
      assert_redirected_to menu_item_url(@menu_item)
      @menu_item.reload
      assert_equal "Updated Sandwich", @menu_item.name
      follow_redirect!
      assert_select "p", text: "Menu item was successfully updated."
    end

    test "updates menu item menu associations" do
        menu3 = create(:menu)
        patch menu_item_url(@menu_item), params: {
            menu_item: { name: @menu_item.name },
            menu_ids: menu3.id.to_s
        }
        @menu_item.reload
        assert_includes @menu_item.menus, menu3
        assert_equal 1, @menu_item.menus.count
    end

    test "fails to update menu item with invalid data" do
      patch menu_item_url(@menu_item), params: { menu_item: { name: "" } }
      assert_response :unprocessable_entity
      assert_select ".text-red-800", /prohibited this menu item from being saved/
    end

    test "destroys menu item" do
      assert_difference("MenuItem.count", -1) do
        delete menu_item_url(@menu_item)
      end

      assert_redirected_to menu_items_url
      follow_redirect!
      assert_select "p", text: "Menu item was successfully destroyed."
    end
  end
end
