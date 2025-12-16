module JsonArraySerializable
  extend ActiveSupport::Concern

  class_methods do
    def json_array_field(attribute)
      define_method(attribute) do
        raw = super()
        begin
          raw.present? ? JSON.parse(raw) : []
        rescue JSON::ParserError
          []
        end
      end

      define_method("#{attribute}=") do |value|
        super(value.is_a?(Array) ? value.to_json : value)
      end
    end
  end
end
