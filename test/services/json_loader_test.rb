require "test_helper"

class JsonLoaderTest < ActiveSupport::TestCase
  test "returns provided json data when present" do
    logger = ImportLogger.new
    loader = JsonLoader.new({ "foo" => "bar" }, nil, logger)

    assert_equal({ "foo" => "bar" }, loader.load)
  end

  test "logs error when file does not exist" do
    logger = ImportLogger.new
    loader = JsonLoader.new(nil, "missing.json", logger)

    result = loader.load

    assert_equal({}, result)
    assert logger.logs.any? { |l| l[:message].include?("could not be found") }
  end

  test "logs error when file contains invalid JSON" do
    path = Rails.root.join("tmp/invalid.json")
    File.write(path, "{ invalid json")

    logger = ImportLogger.new
    loader = JsonLoader.new(nil, "tmp/invalid.json", logger)

    result = loader.load

    assert_equal({}, result)
    assert logger.logs.any? { |l| l[:message].include?("not a valid JSON") }
  ensure
    File.delete(path) if File.exist?(path)
  end
end
