class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery unless: -> { request.format.json? }
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_invalid_json

  def route_not_found
    render json: { error: "Route not found" }, status: :not_found
  end

  private

  def record_not_found
    render json: { error: "Record not found" }, status: :not_found
  end

  def parameter_missing(e)
    render json: { error: e.message }, status: :bad_request
  end

  def render_invalid_json(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
