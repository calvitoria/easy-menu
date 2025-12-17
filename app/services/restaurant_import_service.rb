class RestaurantImportService
  def initialize(json_data, file_name = nil)
    @logger = ImportLogger.new
    @audit_log = ImportAuditLog.create!(
      import_type: "restaurants",
      status: "processing",
      file_name: file_name
    )

    @data = JsonLoader.new(json_data, file_name, @logger).load
    @start_time = Time.current
  end

  def import
    unless @data["restaurants"].is_a?(Array)
      @logger.error("The import file is invalid. It must contain a list of restaurants.")
      return finalize
    end

    ActiveRecord::Base.transaction do
      RestaurantImporter.new(@logger).import(@data["restaurants"])
    end

    finalize
  rescue StandardError => e
    @audit_log.mark_as_failed(e.message)
    failure_response(e)
  end

  private

  def finalize
    ImportFinalizer.new(@audit_log, @logger, @start_time).finalize
  end

  def failure_response(error)
    {
      success: false,
      error: error.message,
      logs: @logger.logs,
      audit_log_id: @audit_log.id
    }
  end
end
