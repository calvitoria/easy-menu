class MenuItemImporter
  ALLOWED_KEYS = %w[name categories description price spicy vegan vegetarian].freeze

  def initialize(logger, menu)
    @logger = logger
    @menu = menu
  end

  def import(items)
    unless items.is_a?(Array)
      @logger.increment(:menu_items, :errors)
      @logger.error("Menu '#{@menu.name}' does not contain menu items.")
      return
    end

    items.each do |data|
      validate_keys(data)

      unless data["name"].present?
        @logger.increment(:menu_items, :errors)
        @logger.error("An item in menu '#{@menu.name}' is missing name.")
        next
      end

      item = MenuItem.find_or_initialize_by(name: data["name"])
      item.price = data["price"].to_f
      item.save!

      @menu.menu_items << item unless @menu.menu_items.exists?(item.id)

      @logger.increment(:menu_items, :created)
      @logger.info("Menu item '#{item.name}' was added to menu '#{@menu.name}'.")
    end
  end

  private

  def validate_keys(data)
    (data.keys - ALLOWED_KEYS).each do |key|
      @logger.increment(:menu_items, :errors)
      @logger.error("An item in menu '#{@menu.name}' contains unsupported field '#{key}'.")
    end
  end
end
