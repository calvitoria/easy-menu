class ImportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    json_file = params[:file]
    
    if json_file.nil?
      return render json: { 
        success: false, 
        error: 'No file provided',
        message: 'Please provide a JSON file using the "file" parameter'
      }, status: :bad_request
    end
    
    unless json_file.content_type == 'application/json'
      return render json: { 
        success: false, 
        error: 'Invalid file type',
        message: 'File must be a JSON file'
      }, status: :bad_request
    end
    
    begin
      json_data = JSON.parse(json_file.read)
      
      unless json_data.is_a?(Hash) && json_data['restaurants'].is_a?(Array)
        return render json: {
          success: false,
          error: 'Invalid JSON structure',
          message: 'JSON must contain a "restaurants" array'
        }, status: :bad_request
      end
      
      service = RestaurantImportService.new(json_data, json_file.original_filename)
      result = service.import
      
      status_code = result[:success] ? :created : :unprocessable_entity
      
      render json: {
        success: result[:success],
        summary: result[:summary],
        stats: result[:stats],
        logs: result[:logs],
        audit_log_id: result[:audit_log_id],
        duration: result[:duration],
        timestamp: Time.current.iso8601
      }, status: status_code
      
    rescue JSON::ParserError => e
      render json: { 
        success: false, 
        error: 'Invalid JSON file',
        details: e.message,
        message: 'The file contains invalid JSON syntax'
      }, status: :bad_request
    rescue => e
      Rails.logger.error("Import failed: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { 
        success: false, 
        error: 'Import failed',
        details: e.message,
        message: 'An unexpected error occurred during import'
      }, status: :internal_server_error
    end
  end
end