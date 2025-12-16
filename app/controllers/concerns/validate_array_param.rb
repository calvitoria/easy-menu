module ValidateArrayParam
  extend ActiveSupport::Concern

  private

  def validate_array_of_strings(*keys, scope: nil)
    validate_array(*keys, scope: scope) { |v| v.is_a?(String) }
  end

  def validate_array_of_ids(*keys, scope: nil)
    validate_array(*keys, scope: scope) { |v| v.is_a?(String) || v.is_a?(Integer) }
  end

  def validate_array(*keys, scope:)
    keys.each do |key|
      value = scope ? params[scope]&.[](key) : params[key]
      next if value.nil?

      unless value.is_a?(Array)
        return render_error("#{key} must be an array")
      end

      unless value.all? { |v| yield(v) }
        return render_error("#{key} must be an array of valid values")
      end
    end
  end

  def render_error(message)
    render json: { errors: [ message ] }, status: :unprocessable_entity
  end
end
