module JsonResponse
  extend ActiveSupport::Concern

  def render_ok(resource, include: nil, status: :ok)
    render json: resource, include: include, status: status
  end

  def render_created(resource, include: nil)
    render json: resource, include: include, status: :created
  end

  def render_no_content
    head :no_content
  end

  def render_errors(resource, status: :unprocessable_entity)
    render json: { errors: resource.errors.full_messages }, status: status
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_service_error(service_result, status: nil)
    status = status || service_result.status || :unprocessable_entity
    render json: { errors: service_result.errors }, status: status
  end

  def render_array_errors(errors_array, status: :unprocessable_entity)
    render json: { errors: errors_array }, status: status
  end
end
