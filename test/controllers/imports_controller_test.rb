require "test_helper"

class ImportsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  def upload_json(path)
    Rack::Test::UploadedFile.new(
      Rails.root.join(path),
      "application/json"
    )
  end

  def upload_temp_json(payload)
    file = Tempfile.new([ "import", ".json" ])
    file.write(payload.to_json)
    file.rewind

    Rack::Test::UploadedFile.new(file.path, "application/json")
  end

  test "returns error when no file is provided" do
    post "/imports/restaurants"

    assert_response :bad_request
    body = JSON.parse(response.body)

    assert_equal false, body["success"]
    assert_equal "No file provided", body["error"]
  end

  test "returns error when file is not json" do
    file = Tempfile.new([ "text", ".txt" ])
    file.write("not json")
    file.rewind

    uploaded = Rack::Test::UploadedFile.new(file.path, "text/plain")

    post "/imports/restaurants", params: { file: uploaded }

    assert_response :bad_request
    body = JSON.parse(response.body)

    assert_equal false, body["success"]
    assert_equal "Invalid file type", body["error"]
  ensure
    file.close
    file.unlink
  end

  test "returns error for invalid json syntax" do
    file = Tempfile.new([ "invalid", ".json" ])
    file.write("{ invalid json")
    file.rewind

    uploaded = Rack::Test::UploadedFile.new(file.path, "application/json")

    post "/imports/restaurants", params: { file: uploaded }

    assert_response :bad_request
    body = JSON.parse(response.body)

    assert_equal false, body["success"]
    assert_equal "Invalid JSON file", body["error"]
  ensure
    file.close
    file.unlink
  end

  test "successfully imports restaurant_data.json" do
    file = upload_json("restaurant_data.json")

    post "/imports/restaurants", params: { file: file }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["success"]
    assert_match(/Processed \d+ records with \d+ errors/, body["summary"])
    assert body["stats"].present?
    assert body["audit_log_id"].present?
    assert body["timestamp"].present?
  end

  test "logs errors but still succeeds when json contains invalid menu structure" do
    file = upload_json("restaurant_data.json")

    post "/imports/restaurants", params: { file: file }

    body = JSON.parse(response.body)

    error_logs = body["logs"].select { |l| l["level"] == "ERROR" }

    assert body["success"]
    assert error_logs.any?
    assert error_logs.any? { |l|
      l["message"].include?("unsupported field") &&
      l["message"].include?("dishes")
    }
  end

  test "handles empty restaurants array gracefully" do
    uploaded = upload_temp_json({ restaurants: [] })

    post "/imports/restaurants", params: { file: uploaded }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["success"]
    assert_equal 0, Restaurant.count
  end

  test "returns success even when restaurant name is missing" do
    uploaded = upload_temp_json(
      {
        restaurants: [
          { menus: [] }
        ]
      }
    )

    post "/imports/restaurants", params: { file: uploaded }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["success"]
    assert body["logs"].any? { |l| l["level"] == "ERROR" }
  end
end
