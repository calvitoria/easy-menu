class ImportsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def index
    @imports = ImportAuditLog.recent

    respond_to do |format|
      format.html
      format.json { render json: @imports }
    end
  end

  def show
    @import = ImportAuditLog.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @import }
    end
  end

  def new
  end

  def create
    file = params[:file]

    unless file
      return render json: error_response(
        error: "No file provided",
        message: "Please provide a JSON file using the \"file\" parameter"
      ), status: :bad_request
    end

    unless json_file?(file)
      return render json: error_response(
        error: "Invalid file type",
        message: "File must be a JSON file"
      ), status: :bad_request
    end

    begin
      json_data = JSON.parse(file.read)
    rescue JSON::ParserError => e
      return render json: error_response(
        error: "Invalid JSON file",
        message: "The file contains invalid JSON syntax",
        details: e.message
      ), status: :bad_request
    end

    result = RestaurantImportService
      .new(json_data, file.original_filename)
      .import

    render_import_result(result)
  end

  private

  def json_file?(file)
    file.content_type == "application/json"
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

  def error_response(error:, message:, details: nil)
    {
      success: false,
      error: error,
      message: message,
      details: details
    }.compact
  end
end
