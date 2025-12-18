class ImportAuditLog < ApplicationRecord
  validates :import_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  serialize :details, coder: JSON

  scope :restaurant_imports, -> { where(import_type: "restaurants") }
  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  before_create :set_defaults

  def set_defaults
    self.status ||= "pending"
  end

  def mark_as_completed(stats = {})
    update(
      status: "completed",
      completed_at: Time.current,
      total_records: stats[:total_records] || 0,
      successful_records: stats[:successful_records] || 0,
      failed_records: stats[:failed_records] || 0,
      details: stats[:details] || {}
    )
  end

  def mark_as_failed(error_message)
    update(
      status: "failed",
      completed_at: Time.current,
      error_message: error_message
    )
  end
end
