class MenuItemAssignmentService
  def self.assign_menus_to_item(menu_item:, menu_ids_param: nil, menu_from_route: nil, menu_item_attributes: nil)
    success = false

    ActiveRecord::Base.transaction do
      if menu_item_attributes.present?
        menu_item.assign_attributes(menu_item_attributes)
      end

      if menu_from_route && !menu_item.menus.include?(menu_from_route)
        menu_item.menus << menu_from_route
      end

      if menu_ids_param.present?
        if menu_ids_param.empty?
          menu_item.menu_item_menus.destroy_all
        else
          menus = Menu.where(id: Array(menu_ids_param))
          if menus.count != menu_ids_param.size
            menu_item.errors.add(:menus, "One or more menus not found")
            raise ActiveRecord::Rollback, "Invalid menu IDs"
          end
          menu_item.menus = menus
        end
      end

      menu_item.save!
      success = true
    end

    if success
      ServiceResult.new(success: true, data: { menu_item: menu_item })
    else
      ServiceResult.new(success: false, errors: menu_item.errors.full_messages)
    end
  rescue ActiveRecord::RecordInvalid => e
    ServiceResult.new(success: false, errors: e.record.errors.full_messages)
  rescue ActiveRecord::Rollback => e
    ServiceResult.new(success: false, errors: menu_item.errors.any? ? menu_item.errors.full_messages : [ e.message ])
  end
end
