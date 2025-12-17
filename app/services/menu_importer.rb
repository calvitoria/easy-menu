class MenuImporter
  ALLOWED_KEYS = %w[name menu_items categories active description].freeze

  def initialize(logger, restaurant)
    @logger = logger
    @restaurant = restaurant
  end

  def import(menus)
    unless menus.is_a?(Array)
      @logger.increment(:menus, :errors)
      @logger.error("Restaurant '#{@restaurant.name}' does not contain a valid list of menus.")
      return
    end

    menus.each do |data|
      validate_keys(data)

      unless data["name"].present?
        @logger.increment(:menus, :errors)
        @logger.error("A menu in restaurant '#{@restaurant.name}' is missing its name.")
        next
      end

      menu = @restaurant.menus.find_or_create_by!(name: data["name"])
      @logger.increment(:menus, :created)
      @logger.info("Menu '#{menu.name}' was added to restaurant '#{@restaurant.name}'.")

      MenuItemImporter.new(@logger, menu).import(data["menu_items"]) if data["menu_items"].present?
    end
  end

  private

  def validate_keys(data)
    (data.keys - ALLOWED_KEYS).each do |key|
      @logger.increment(:menus, :errors)
      @logger.error(
        "Menu '#{data['name'] || 'unknown'}' contains an unsupported field: '#{key}'."
      )
    end
  end
end
