class MenuItemsController < ApplicationController
  load_resource :menu, param: :menu_id, only: [ :index, :create ]
  load_resource :menu_item, only: [ :show, :update, :destroy ]

  before_action only: [ :create, :update ] do
    validate_array_of_strings :categories, scope: :menu_item
    validate_array_of_ids :menu_ids if params.key?(:menu_ids)
  end

  def index
    if @menu
      @menu_items = @menu.menu_items.with_associations
      render_ok(@menu_items, include: :menus)
    else
      @menu_items = MenuItem.with_associations
      render_ok(@menu_items, include: :menus)
    end
  end

  def show
    render_ok(@menu_item, include: :menus)
  end

  def create
    @menu_item = MenuItem.new

    result = MenuItemAssignmentService.assign_menus_to_item(
      menu_item: @menu_item,
      menu_ids_param: params[:menu_ids],
      menu_from_route: @menu,
      menu_item_attributes: menu_item_params
    )

    if result.success
      render_created(result.data[:menu_item], include: :menus)
    else
      render_service_error(result)
    end
  end

  def update
    result = MenuItemAssignmentService.assign_menus_to_item(
      menu_item: @menu_item,
      menu_ids_param: params[:menu_ids],
      menu_from_route: nil,
      menu_item_attributes: menu_item_params
    )

    if result.success
      render_ok(@menu_item, include: :menus)
    else
      render_service_error(result)
    end
  end

  def destroy
    @menu_item.destroy
    render_no_content
  end

  private

  def menu_item_params
    params.require(:menu_item).permit(
      :name,
      :price,
      :vegan,
      :vegetarian,
      :description,
      :spicy,
      categories: []
    )
  end
end
