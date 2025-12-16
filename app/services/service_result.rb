class ServiceResult
  attr_reader :success, :data, :errors, :status

  def initialize(success:, data: nil, errors: [], status: :unprocessable_entity)
    @success = success
    @data = data
    @errors = errors.is_a?(Array) ? errors : [ errors ]
    @status = status
  end

  def success?
    success
  end

  def failure?
    !success
  end
end
