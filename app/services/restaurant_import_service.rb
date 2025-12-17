class RestaurantImportService
  # TODO: Fix error handling. atm some errors get ignored and not logged. like "dishes"
  # TODO: ADD TESTS
  # TODO: Break into smaller services - restaurants, menus, menu item, etc.

  def initialize(json_data, file_name = nil)
    @json_data = json_data
    @file_name = file_name
    @logs = []
    @import_stats = {
      restaurants: { created: 0, updated: 0, errors: 0 },
      menus: { created: 0, updated: 0, errors: 0 },
      menu_items: { created: 0, updated: 0, errors: 0 }
    }
    @start_time = Time.current
    @success_count = 0
  end

  def import
    @audit_log = ImportAuditLog.create!(
      import_type: 'restaurants',
      status: 'processing',
      file_name: @file_name
    )
    
    @audit_log.mark_as_processing
    
    begin
      ActiveRecord::Base.transaction do
        import_restaurants
      end
      
      total_records = @import_stats.values.sum { |stat| stat[:created] + stat[:updated] + stat[:errors] }
      successful_records = @import_stats.values.sum { |stat| stat[:created] + stat[:updated] }
      failed_records = @import_stats.values.sum { |stat| stat[:errors] }
      
      @audit_log.mark_as_completed(
        total_records: total_records,
        successful_records: successful_records,
        failed_records: failed_records,
        details: {
          stats: @import_stats,
          logs: @logs,
          duration: Time.current - @start_time
        }
      )
      
      {
        success: true,
        summary: "Processed #{total_records} records with #{failed_records} errors",
        stats: @import_stats,
        logs: @logs,
        audit_log_id: @audit_log.id,
        duration: Time.current - @start_time
      }
      
    rescue StandardError => e
      @audit_log.mark_as_failed(e.message)
      
      {
        success: false,
        error: e.message,
        logs: @logs,
        audit_log_id: @audit_log.id,
        backtrace: Rails.env.development? ? e.backtrace : nil
      }
    end
  end

  private

  def import_restaurants
    return unless @json_data['restaurants']
    
    @json_data['restaurants'].each_with_index do |restaurant_data, index|
      begin
        restaurant = Restaurant.find_by(name: restaurant_data['name'])
        
        if restaurant
          update_restaurant(restaurant, restaurant_data)
          log_info("Updated existing restaurant: #{restaurant.name}")
          @import_stats[:restaurants][:updated] += 1
        else
          restaurant = create_restaurant(restaurant_data)
          log_info("Created new restaurant: #{restaurant.name}")
          @import_stats[:restaurants][:created] += 1
        end
        
        import_menus(restaurant, restaurant_data['menus']) if restaurant_data['menus']
        
        @success_count += 1
      rescue => e
        @import_stats[:restaurants][:errors] += 1
        log_error("Failed to process restaurant ##{index + 1} '#{restaurant_data['name']}': #{e.message}")
      end
    end
  end

  def update_restaurant(restaurant, data)
    update_attributes = extract_valid_attributes(Restaurant, data)
    
    if update_attributes.any?
      if restaurant.update(update_attributes)
        log_info("Updated restaurant #{restaurant.name} with: #{update_attributes.keys.join(', ')}")
      else
        log_error("Failed to update restaurant #{restaurant.name}: #{restaurant.errors.full_messages.join(', ')}")
        raise "Restaurant update failed"
      end
    end
  end

  def create_restaurant(data)
    create_attributes = extract_valid_attributes(Restaurant, data)
    
    restaurant = Restaurant.new(create_attributes)
    if restaurant.save
      restaurant
    else
      log_error("Failed to create restaurant: #{restaurant.errors.full_messages.join(', ')}")
      raise "Restaurant creation failed"
    end
  end

  def import_menus(restaurant, menus_data)
    menus_data.each_with_index do |menu_data, index|
      begin
        menu = restaurant.menus.find_by(name: menu_data['name'])
        
        if menu
          update_menu(menu, menu_data)
          log_info("Updated existing menu: #{menu.name} in #{restaurant.name}")
          @import_stats[:menus][:updated] += 1
        else
          menu = create_menu(restaurant, menu_data)
          log_info("Created new menu: #{menu.name} in #{restaurant.name}")
          @import_stats[:menus][:created] += 1
        end
        
        items_data = menu_data['menu_items']
        import_menu_items(menu, items_data) if items_data
        
      rescue => e
        @import_stats[:menus][:errors] += 1
        log_error("Failed to process menu ##{index + 1} '#{menu_data['name']}' in #{restaurant.name}: #{e.message}")
      end
    end
  end

  def update_menu(menu, data)
    update_attributes = extract_valid_attributes(Menu, data)
    
    if data['categories']
      update_attributes['categories'] = data['categories']
    end
    
    if data.key?('active')
      update_attributes['active'] = [true, 'true', 1].include?(data['active'])
    end
    
    if update_attributes.any?
      if menu.update(update_attributes)
        log_info("Updated menu #{menu.name} with: #{update_attributes.keys.join(', ')}")
      else
        log_error("Failed to update menu #{menu.name}: #{menu.errors.full_messages.join(', ')}")
        raise "Menu update failed"
      end
    end
  end

  def create_menu(restaurant, data)
    create_attributes = extract_valid_attributes(Menu, data)
    create_attributes['restaurant'] = restaurant
    
    create_attributes['categories'] = data['categories'] if data['categories']
    
    create_attributes['active'] = data.key?('active') ? 
      [true, 'true', 1].include?(data['active']) : true
    
    menu = Menu.new(create_attributes)
    if menu.save
      menu
    else
      log_error("Failed to create menu: #{menu.errors.full_messages.join(', ')}")
      raise "Menu creation failed"
    end
  end

  def import_menu_items(menu, items_data)
    items_data.each_with_index do |item_data, index|
      begin
        menu_item = MenuItem.find_by(name: item_data['name'])
        
        if menu_item
          update_menu_item(menu_item, item_data)
          log_info("Updated existing menu item: #{menu_item.name}")
          @import_stats[:menu_items][:updated] += 1
        else
          menu_item = create_menu_item(item_data)
          log_info("Created new menu item: #{menu_item.name}")
          @import_stats[:menu_items][:created] += 1
        end
        
        unless menu.menu_items.include?(menu_item)
          menu.menu_items << menu_item
          log_info("Added menu item '#{menu_item.name}' to menu '#{menu.name}'")
        end
        
      rescue ActiveRecord::RecordNotUnique => e
        @import_stats[:menu_items][:errors] += 1
        log_error("Duplicate menu item detected: #{item_data['name']}")
      rescue => e
        @import_stats[:menu_items][:errors] += 1
        log_error("Failed to process menu item ##{index + 1} '#{item_data['name']}': #{e.message}")
      end
    end
  end

  def update_menu_item(menu_item, data)
    update_attributes = extract_valid_attributes(MenuItem, data)
    
    if data['price']
      update_attributes['price'] = data['price'].to_f
    end
    
    if update_attributes.any?
      if menu_item.update(update_attributes)
        log_info("Updated menu item #{menu_item.name} with: #{update_attributes.keys.join(', ')}")
      else
        log_error("Failed to update menu item #{menu_item.name}: #{menu_item.errors.full_messages.join(', ')}")
        raise "Menu item update failed"
      end
    end
  end

  def create_menu_item(data)
    create_attributes = extract_valid_attributes(MenuItem, data)
    
    create_attributes['price'] = data['price'].to_f if data['price']
    
    menu_item = MenuItem.new(create_attributes)
    if menu_item.save
      menu_item
    else
      log_error("Failed to create menu item: #{menu_item.errors.full_messages.join(', ')}")
      raise "Menu item creation failed"
    end
  end

  def extract_valid_attributes(model_class, data)
    valid_attributes = model_class.column_names.map(&:to_sym)
    data.select { |key, _| valid_attributes.include?(key.to_sym) }
  end

  def log_info(message)
    @logs << {
      timestamp: Time.current.strftime('%Y-%m-%d %H:%M:%S'),
      level: 'INFO',
      message: message
    }
    Rails.logger.info(message) if Rails.logger
  end

  def log_error(message)
    @logs << {
      timestamp: Time.current.strftime('%Y-%m-%d %H:%M:%S'),
      level: 'ERROR',
      message: message
    }
    Rails.logger.error(message) if Rails.logger
  end

  def generate_summary
    total_processed = @import_stats.values.sum { |stat| stat[:created] + stat[:updated] + stat[:errors] }
    total_errors = @import_stats.values.sum { |stat| stat[:errors] }
    
    "Processed #{total_processed} records with #{total_errors} errors"
  end
end