require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  setup do
    @restaurant = create(:restaurant)
  end

  test "should get index" do
    get restaurants_url
    assert_response :success
    assert_not_nil JSON.parse(response.body)
  end

  test "should show restaurant" do
    get restaurant_url(@restaurant)
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @restaurant.name, body["name"]
    assert_equal @restaurant.email, body["email"]
  end

  test "should create restaurant" do
    assert_difference("Restaurant.count") do
      post restaurants_url, params: {
        restaurant: {
          name: "New Restaurant",
          email: "new@example.com",
          description: "A new restaurant",
          address: "123 New St"
        }
      }
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "New Restaurant", body["name"]
  end

  test "should not create restaurant with invalid data" do
    assert_no_difference("Restaurant.count") do
      post restaurants_url, params: {
        restaurant: {
          name: ""
        }
      }
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name can't be blank"
  end

  test "should update restaurant" do
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: "Updated Name"
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal "Updated Name", @restaurant.name
  end

  test "should destroy restaurant" do
    assert_difference("Restaurant.count", -1) do
      delete restaurant_url(@restaurant)
    end

    assert_response :no_content
  end

  test "should return 404 for non-existent restaurant" do
    get restaurant_url(999999)
    assert_response :not_found
    body = JSON.parse(response.body)
    assert_equal "Restaurant not found", body["error"]
  end

  # NEW TESTS BASED ON SCHEMA

  test "index includes nested menus with their menu_items" do
    menu = create(:menu, restaurant: @restaurant)
    menu_item = create(:menu_item)
    menu.menu_items << menu_item

    get restaurants_url
    assert_response :success

    body = JSON.parse(response.body)
    restaurant_data = body.first
    assert_includes restaurant_data.keys, "menus"
    assert_equal 1, restaurant_data["menus"].length
    assert_equal menu.name, restaurant_data["menus"].first["name"]
    assert_includes restaurant_data["menus"].first.keys, "menu_items"
    assert_equal 1, restaurant_data["menus"].first["menu_items"].length
  end

  test "show includes nested menus with their menu_items" do
    menu = create(:menu, restaurant: @restaurant)
    menu_item = create(:menu_item)
    menu.menu_items << menu_item

    get restaurant_url(@restaurant)
    assert_response :success

    body = JSON.parse(response.body)
    assert_includes body.keys, "menus"
    assert_equal 1, body["menus"].length
    assert_equal menu.name, body["menus"].first["name"]
    assert_includes body["menus"].first.keys, "menu_items"
    assert_equal 1, body["menus"].first["menu_items"].length
  end

  test "cannot create restaurant with duplicate case-insensitive name" do
    create(:restaurant, name: "Original Name")

    assert_no_difference("Restaurant.count") do
      post restaurants_url, params: {
        restaurant: {
          name: "ORIGINAL NAME",  # Different case
          email: "test@example.com"
        }
      }
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name has already been taken"
  end

  test "cannot update restaurant to duplicate case-insensitive name" do
    other_restaurant = create(:restaurant, name: "Other Restaurant")

    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: "other restaurant"  # lowercase
      }
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name has already been taken"
  end

  test "can update restaurant with same name (case-insensitive)" do
    original_name = @restaurant.name
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: original_name.upcase  # Same name, different case
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal original_name.upcase, @restaurant.name
  end

  test "restaurant destruction cascades to menus but not menu_items" do
    menu = create(:menu, restaurant: @restaurant)
    menu_item = create(:menu_item)
    menu.menu_items << menu_item

    assert_difference("Restaurant.count", -1) do
      assert_difference("Menu.count", -1) do
        assert_difference("MenuItemMenu.count", -1) do
          assert_no_difference("MenuItem.count") do  # MenuItem should not be destroyed
            delete restaurant_url(@restaurant)
          end
        end
      end
    end

    assert_response :no_content
  end

  test "should handle all permitted parameters in create" do
    restaurant_params = {
      name: "Complete Restaurant",
      email: "complete@example.com",
      description: "Full description",
      address: "123 Main St"
    }

    assert_difference("Restaurant.count", 1) do
      post restaurants_url, params: { restaurant: restaurant_params }
    end

    assert_response :created
    restaurant = Restaurant.last
    restaurant_params.each do |key, value|
      assert_equal value, restaurant.send(key)
    end
  end

  test "should handle all permitted parameters in update" do
    update_params = {
      name: "Updated Name",
      email: "updated@example.com",
      description: "Updated description",
      address: "456 Updated St"
    }

    patch restaurant_url(@restaurant), params: { restaurant: update_params }

    assert_response :success
    @restaurant.reload
    update_params.each do |key, value|
      assert_equal value, @restaurant.send(key)
    end
  end

  test "should handle malformed JSON request" do
    post restaurants_url,
         params: "{malformed: json",
         headers: { "CONTENT_TYPE" => "application/json" }

    begin
      assert_response :unprocessable_entity
    rescue ActionDispatch::Http::Parameters::ParseError
      assert true
    end
  end

  test "should require restaurant parameter" do
    post restaurants_url, params: {}
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert_includes body["error"], "param is missing"
  end

  test "should handle update with invalid email format" do
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        email: "invalid-email-format"
      }
    }

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Email is invalid"
  end

  test "should accept blank email" do
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        email: ""
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal "", @restaurant.email
  end

  test "should accept nil email" do
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        email: nil
      }
    }

    assert_response :success
    @restaurant.reload
    assert_nil @restaurant.email
  end

  test "should create restaurant with nil email" do
    assert_difference("Restaurant.count") do
      post restaurants_url, params: {
        restaurant: {
          name: "No Email Restaurant",
          email: nil
        }
      }
    end

    assert_response :created
    restaurant = Restaurant.last
    assert_nil restaurant.email
  end

  test "should handle very long name" do
    long_name = "A" * 100
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: long_name
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal long_name, @restaurant.name
  end

  test "should handle update with all empty values" do
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: "",
        email: "",
        description: "",
        address: ""
      }
    }

    # Name is required, so this should fail
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name can't be blank"
  end

  test "should handle partial updates" do
    original_email = @restaurant.email
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        description: "Only updating description"
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal "Only updating description", @restaurant.description
    assert_equal original_email, @restaurant.email
  end

  test "should return proper JSON structure for index" do
    get restaurants_url
    assert_response :success

    body = JSON.parse(response.body)
    assert_kind_of Array, body

    if body.any?
      restaurant = body.first
      assert_includes restaurant.keys, "id"
      assert_includes restaurant.keys, "name"
      assert_includes restaurant.keys, "email"
      assert_includes restaurant.keys, "description"
      assert_includes restaurant.keys, "address"
      assert_includes restaurant.keys, "created_at"
      assert_includes restaurant.keys, "updated_at"
      assert_includes restaurant.keys, "menus"
    end
  end

  test "should handle restaurant with special characters in name" do
    special_name = "Restaurant & Bar 'El Niño' Café"
    patch restaurant_url(@restaurant), params: {
      restaurant: {
        name: special_name
      }
    }

    assert_response :success
    @restaurant.reload
    assert_equal special_name, @restaurant.name
  end
end
