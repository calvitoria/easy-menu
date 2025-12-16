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
          name: "",
          email: "invalid-email"
        }
      }
    end

    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_includes body["errors"], "Name can't be blank"
    assert_includes body["errors"], "Email is invalid"
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
end
