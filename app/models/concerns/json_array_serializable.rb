module JsonArraySerializable
  extend ActiveSupport::Concern

  class_methods do
    def json_array_field(attribute)
      define_method(attribute) do
        JSON.parse(super() || "[]")
      rescue JSON::ParserError
        []
      end

      define_method("#{attribute}=") do |value|
        super(value.to_json)
      end
    end
  end
end
