class MenuManagementService
  def self.add_menu_item(menu, menu_item_id)
    menu_item = MenuItem.find(menu_item_id)

    if menu.add_menu_item(menu_item)
      ServiceResult.new(success: true, data: { menu: menu, menu_item: menu_item })
    else
      ServiceResult.new(success: false, errors: menu.errors.full_messages)
    end
  rescue ActiveRecord::RecordNotFound
    ServiceResult.new(success: false, errors: [ "Menu item not found" ], status: :not_found)
  end

  def self.remove_menu_item(menu, menu_item_id)
    menu_item = MenuItem.find(menu_item_id)

    if menu.remove_menu_item(menu_item)
      ServiceResult.new(success: true, data: { menu: menu })
    else
      ServiceResult.new(success: false, errors: menu.errors.full_messages)
    end
  rescue ActiveRecord::RecordNotFound
    ServiceResult.new(success: false, errors: [ "Menu item not found" ], status: :not_found)
  end
end
