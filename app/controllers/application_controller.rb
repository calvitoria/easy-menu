class ApplicationController < ActionController::Base
  include LoadResource
  include ValidateArrayParam
  include JsonResponse

  allow_browser versions: :modern

  protect_from_forgery unless: -> { request.format.json? }
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_invalid_json

  def route_not_found
    render_error("Route not found", status: :not_found)
  end

  private

  def record_not_found(exception)
    render_error("Record not found", status: :not_found)
  end

  def record_invalid(exception)
    render_errors(exception.record, status: :unprocessable_entity)
  end

  def parameter_missing(e)
    render_error(e.message, status: :bad_request)
  end

  def render_invalid_json(e)
    render_error(e.message, status: :unprocessable_entity)
  end
end
