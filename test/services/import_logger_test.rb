require "test_helper"

class ImportLoggerTest < ActiveSupport::TestCase
  test "increments stats correctly" do
    logger = ImportLogger.new

    logger.increment(:restaurants, :created)
    logger.increment(:menus, :errors)

    assert_equal 1, logger.stats[:restaurants][:created]
    assert_equal 1, logger.stats[:menus][:errors]
  end

  test "stores info and error logs" do
    logger = ImportLogger.new

    logger.info("All good")
    logger.error("Something broke")

    assert_equal 2, logger.logs.size
    assert_equal "INFO", logger.logs.first[:level]
    assert_equal "ERROR", logger.logs.last[:level]
  end
end
