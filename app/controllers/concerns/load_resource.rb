module LoadResource
  extend ActiveSupport::Concern

  class_methods do
    def load_resource(name, options = {})
      before_action(options) do
        model_class = name.to_s.classify.constantize
        param_key   = options[:param] || :id
        instance_var = "@#{name}"

        if params[param_key].present?
          record = model_class.find(params[param_key])
          instance_variable_set(instance_var, record)
        else
          instance_variable_set(instance_var, nil)
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "#{name.to_s.humanize} not found" }, status: :not_found
      end
    end
  end
end
