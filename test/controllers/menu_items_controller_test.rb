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

  test "GET /menus/:menu_id/menu_items returns menu items for the specific menu" do
    other_menu = create(:menu, restaurant: @restaurant)
    other_item = create(:menu_item)
    other_menu.menu_items << other_item

    get "/menus/#{@menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 1, json.length
    assert_equal @menu_item.id, json[0]["id"]
    assert_equal @menu_item.name, json[0]["name"]
  end

  test "GET /menu_items/:id returns a single menu item with menus" do
    get "/menu_items/#{@menu_item.id}"
    assert_response :success
    json = JSON.parse(@response.body)
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

  test "GET /menu_items/:id returns 404 for non-existent menu item" do
    get "/menu_items/99999"
    assert_response :not_found
  end

  test "GET /menu_items returns all menu items with menus" do
    item2 = create(:menu_item)
    item3 = create(:menu_item)

    @menu.menu_items << item2
    @menu2.menu_items << item3

    get "/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)

    assert json.length >= 3

    json.each do |item|
      assert item.key?("menus")
      assert_kind_of Array, item["menus"]
    end
  end

  test "POST /menus/:menu_id/menu_items creates a new menu item and associates with menu" do
    assert_difference("MenuItem.count") do
      assert_difference("MenuItemMenu.count", 1) do
        post "/menus/#{@menu.id}/menu_items", params: {
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
    json = JSON.parse(@response.body)
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

  test "POST /menu_items creates a new menu item with multiple menu associations" do
    assert_difference("MenuItem.count") do
      assert_difference("MenuItemMenu.count", 2) do
        post "/menu_items", params: {
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
    json = JSON.parse(@response.body)
    assert_equal "Global Item", json["name"]

    assert_equal 2, json["menus"].length
    menu_ids = json["menus"].map { |m| m["id"] }
    assert_includes menu_ids, @menu.id
    assert_includes menu_ids, @menu2.id
  end

  test "POST /menu_items creates a menu item without menu associations" do
    assert_difference("MenuItem.count") do
      assert_no_difference("MenuItemMenu.count") do
        post "/menu_items", params: {
          menu_item: {
            name: "Standalone Item",
            price: 8.99
          }
        }, as: :json
      end
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "Standalone Item", json["name"]
    assert_empty json["menus"]
  end

  test "POST /menus/:menu_id/menu_items fails when categories is not an array" do
    assert_no_difference("MenuItem.count") do
      post "/menus/#{@menu.id}/menu_items",
           params: {
             menu_item: {
               name: "Invalid Categories Item",
               price: 10.0,
               categories: "Appetizer"
             }
           },
           as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "categories must be an array"
  end

  test "POST /menus/:menu_id/menu_items fails with invalid params" do
    post "/menus/#{@menu.id}/menu_items", params: { menu_item: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "POST /menu_items fails with duplicate name" do
    create(:menu_item, name: "Unique Item")

    assert_no_difference("MenuItem.count") do
      post "/menu_items", params: {
        menu_item: {
          name: "Unique Item",
          price: 12.99
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name has already been taken"
  end

  test "PUT /menu_items/:id updates a menu item" do
    put "/menu_items/#{@menu_item.id}", params: {
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

  test "PUT /menu_items/:id updates menu associations with menu_ids" do
    menu3 = create(:menu, restaurant: @restaurant)

    put "/menu_items/#{@menu_item.id}", params: {
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

  test "PUT /menu_items/:id removes all associations with empty menu_ids" do
    put "/menu_items/#{@menu_item.id}", params: {
      menu_item: {
        price: 19.99
      },
      menu_ids: []
    }, as: :json
    assert_response :success

    @menu_item.reload
    assert_equal 19.99, @menu_item.price
    assert_empty @menu_item.menus
  end

  test "PUT /menu_items/:id fails with invalid params" do
    put "/menu_items/#{@menu_item.id}", params: { menu_item: { name: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "Name can't be blank"
  end

  test "PUT /menu_items/:id fails when categories is not an array" do
    put "/menu_items/#{@menu_item.id}",
        params: {
          menu_item: {
            categories: "Main Course"
          }
        },
        as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert_includes json["errors"], "categories must be an array"
  end

  test "DELETE /menu_items/:id destroys a menu item and its associations" do
    assert_difference "MenuItem.count", -1 do
      assert_difference "MenuItemMenu.count", -2 do
        delete "/menu_items/#{@menu_item.id}"
      end
    end
    assert_response :no_content
    assert_not MenuItem.exists?(@menu_item.id)

    assert Menu.exists?(@menu.id)
    assert Menu.exists?(@menu2.id)
  end

  test "DELETE /menu_items/:id returns 404 for non-existent menu item" do
    delete "/menu_items/99999"
    assert_response :not_found
  end

  test "GET /menus/:menu_id/menu_items returns empty array when menu has no items" do
    empty_menu = create(:menu, restaurant: @restaurant)
    get "/menus/#{empty_menu.id}/menu_items"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal [], json
  end

  test "POST /menu_items with invalid menu_ids handles gracefully" do
    assert_no_difference("MenuItem.count") do
      post "/menu_items", params: {
        menu_item: {
          name: "Test Item",
          price: 9.99
        },
        menu_ids: [ 99999 ]
      }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "One or more menus not found", json["error"]
  end

  test "PUT /menu_items/:id with invalid menu_ids handles gracefully" do
    put "/menu_items/#{@menu_item.id}", params: {
      menu_item: {
        price: 20.99
      },
      menu_ids: [ 99999 ]
    }, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "One or more menus not found", json["error"]
  end

  test "Menu item can be associated with multiple menus" do
    menu3 = create(:menu, restaurant: @restaurant)

    @menu_item.menus << menu3

    get "/menu_items/#{@menu_item.id}"
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 3, json["menus"].length
  end
end
