require "test_helper"

class ImportFinalizerTest < ActiveSupport::TestCase
  test "returns summary, duration and marks audit log completed" do
    logger = ImportLogger.new
    logger.increment(:restaurants, :created)
    logger.increment(:menus, :errors)

    audit_log = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "processing"
    )

    result = ImportFinalizer.new(audit_log, logger, Time.current).finalize

    assert result[:success]
    assert_match(/Processed \d+ records/, result[:summary])
    assert result[:duration].is_a?(Numeric)

    audit_log.reload
    assert_equal "completed", audit_log.status
  end
end
