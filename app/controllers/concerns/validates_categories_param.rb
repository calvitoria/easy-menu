module ValidatesCategoriesParam
  extend ActiveSupport::Concern

  private

  def validate_categories_param
    return unless params[:menu]&.key?(:categories) || params[:menu_item]&.key?(:categories)

    resource_key =
      params[:menu] ? :menu : :menu_item

    categories = params[resource_key][:categories]

    unless categories.is_a?(Array)
      render json: {
        errors: [ "categories must be an array of strings" ]
      }, status: :unprocessable_entity
    end
  end
end
