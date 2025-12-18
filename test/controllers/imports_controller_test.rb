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

  test "GET /imports returns list of imports" do
    import = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "completed",
      total_records: 10,
      successful_records: 8,
      failed_records: 2,
      created_at: Time.current,
      completed_at: Time.current + 5.seconds
    )

    get imports_path

    assert_response :success
    assert_select "h2", "Import History"
  end

  test "GET /imports/:id shows import details" do
    import = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "completed",
      total_records: 10,
      successful_records: 8,
      failed_records: 2,
      created_at: Time.current,
      completed_at: Time.current + 5.seconds
    )

    get import_path(import)

    assert_response :success
    assert_select "h2", "Import Details"
  end

  test "GET /imports/new/restaurants shows upload form" do
    get new_import_restaurants_path

    assert_response :success
    assert_select "h2", "Import Restaurants"
    assert_select "form[action='#{import_restaurants_path}']"
  end

  test "returns error when no file is provided" do
    post import_restaurants_path

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

    post import_restaurants_path, params: { file: uploaded }

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

    post import_restaurants_path, params: { file: uploaded }

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

    post import_restaurants_path, params: { file: file }

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

    post import_restaurants_path, params: { file: file }

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

    post import_restaurants_path, params: { file: uploaded }

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

    post import_restaurants_path, params: { file: uploaded }

    assert_response :created
    body = JSON.parse(response.body)

    assert body["success"]
    assert body["logs"].any? { |l| l["level"] == "ERROR" }
  end

  test "GET /imports.json returns JSON list" do
    import = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "completed",
      total_records: 10,
      successful_records: 8,
      failed_records: 2,
      created_at: Time.current,
      completed_at: Time.current + 5.seconds
    )

    get imports_path(format: :json)

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal import.id, json.first["id"]
  end

  test "GET /imports/:id.json returns JSON" do
    import = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "completed",
      total_records: 10,
      successful_records: 8,
      failed_records: 2,
      created_at: Time.current,
      completed_at: Time.current + 5.seconds
    )

    get import_path(import, format: :json)

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal import.id, json["id"]
    assert_equal import.import_type, json["import_type"]
  end

  test "GET /imports with no imports shows empty state" do
    ImportAuditLog.destroy_all

    get imports_path

    assert_response :success
    assert_select "h3", "No imports yet"
  end
end
