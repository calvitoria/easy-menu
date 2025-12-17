class RestaurantImporter
  ALLOWED_KEYS = %w[name menus address description email].freeze
  UPDATABLE_ATTRIBUTES = %w[address description email].freeze

  def initialize(logger)
    @logger = logger
  end

  def import(restaurants)
    restaurants.each do |data|
      validate_keys(data, ALLOWED_KEYS, :restaurants, data["name"])

      unless data["name"].present?
        @logger.increment(:restaurants, :errors)
        @logger.error("A restaurant entry is missing its name and was skipped.")
        next
      end

      restaurant = Restaurant.find_or_initialize_by(name: data["name"])

      assign_attributes(restaurant, data)

      if restaurant.new_record?
        restaurant.save!
        @logger.increment(:restaurants, :created)
        @logger.info("Restaurant '#{restaurant.name}' was created by import.")
      else
        restaurant.save!
        @logger.increment(:restaurants, :updated)
        @logger.info("Restaurant '#{restaurant.name}' was updated by import.")
      end

      MenuImporter.new(@logger, restaurant).import(data["menus"])
    end
  end

  private

  def assign_attributes(restaurant, data)
    restaurant.assign_attributes(
      data.slice(*UPDATABLE_ATTRIBUTES)
    )
  end

  def validate_keys(data, allowed, scope, name)
    (data.keys - allowed).each do |key|
      @logger.increment(scope, :errors)
      @logger.error(
        "#{scope.to_s.singularize.capitalize} '#{name || 'unknown'}' contains an unsupported field: '#{key}'."
      )
    end
  end
end
