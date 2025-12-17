class ImportFinalizer
  def initialize(audit_log, logger, start_time)
    @audit_log = audit_log
    @logger = logger
    @start_time = start_time
  end

  def finalize
    total = @logger.stats.values.sum { |s| s.values.sum }
    failed = @logger.stats.values.sum { |s| s[:errors] }
    duration = Time.current - @start_time

    summary = "Processed #{total} records with #{failed} errors"

    @audit_log.mark_as_completed(
      total_records: total,
      successful_records: total - failed,
      failed_records: failed,
      details: {
        stats: @logger.stats,
        logs: @logger.logs,
        duration: duration
      }
    )

    {
      success: true,
      summary: summary,
      stats: @logger.stats,
      logs: @logger.logs,
      audit_log_id: @audit_log.id,
      duration: duration
    }
  end
end
