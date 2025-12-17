class ImportAuditLog < ApplicationRecord
  validates :import_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  
  serialize :details, coder: JSON

  scope :restaurant_imports, -> { where(import_type: 'restaurants') }
  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  
  before_create :set_defaults
  
  def set_defaults
    self.status ||= 'pending'
  end
  
  def success_rate
    return 0 if total_records.zero?
    (successful_records.to_f / total_records * 100).round(2)
  end
  
  def duration
    return nil unless completed_at.present? && started_at.present?
    completed_at - started_at
  end
  
  def completed?
    status == 'completed'
  end
  
  def failed?
    status == 'failed'
  end
  
  def processing?
    status == 'processing'
  end
  
  def mark_as_processing
    update(status: 'processing', started_at: Time.current)
  end
  
  def mark_as_completed(stats = {})
    update(
      status: 'completed',
      completed_at: Time.current,
      total_records: stats[:total_records] || 0,
      successful_records: stats[:successful_records] || 0,
      failed_records: stats[:failed_records] || 0,
      details: stats[:details] || {}
    )
  end
  
  def mark_as_failed(error_message)
    update(
      status: 'failed',
      completed_at: Time.current,
      error_message: error_message
    )
  end
end