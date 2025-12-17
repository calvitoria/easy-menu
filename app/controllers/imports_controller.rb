class ImportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    file = params[:file]
    return render_no_file unless file
    return render_invalid_type unless json_file?(file)

    json_data = parse_json(file)
    return unless json_data

    result = RestaurantImportService
      .new(json_data, file.original_filename)
      .import

    render_import_result(result)
  end

  private

  def json_file?(file)
    file.content_type == "application/json"
  end

  def parse_json(file)
    JSON.parse(file.read)
  rescue JSON::ParserError => e
    render json: error_response(
      error: "Invalid JSON file",
      message: "The file contains invalid JSON syntax",
      details: e.message
    ), status: :bad_request
    nil
  end

  def render_import_result(result)
    render json: {
      success: result[:success],
      summary: result[:summary],
      stats: result[:stats],
      logs: result[:logs],
      audit_log_id: result[:audit_log_id],
      duration: result[:duration],
      timestamp: Time.current.iso8601
    }, status: result[:success] ? :created : :unprocessable_entity
  end

  def render_no_file
    render json: error_response(
      error: "No file provided",
      message: "Please provide a JSON file using the \"file\" parameter"
    ), status: :bad_request
  end

  def render_invalid_type
    render json: error_response(
      error: "Invalid file type",
      message: "File must be a JSON file"
    ), status: :bad_request
  end

  def error_response(error:, message:, details: nil)
    {
      success: false,
      error: error,
      message: message,
      details: details
    }.compact
  end
end
