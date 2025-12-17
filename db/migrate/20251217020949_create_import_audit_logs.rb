class CreateImportAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :import_audit_logs do |t|
      t.string :import_type, null: false
      t.string :status, null: false
      t.string :file_name
      t.integer :total_records, default: 0
      t.integer :successful_records, default: 0
      t.integer :failed_records, default: 0
      t.text :details
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :import_audit_logs, :status
    add_index :import_audit_logs, :import_type
    add_index :import_audit_logs, :created_at
  end
end
