class MenusController < ApplicationController
  load_resource :menu, only: [ :show, :update, :destroy, :add_menu_item, :remove_menu_item ]
  load_resource :restaurant, param: :restaurant_id, only: [ :create ]

  before_action only: [ :create, :update ] do
    validate_array_of_strings :categories, scope: :menu
  end

  def index
    if params[:restaurant_id]
      @restaurant = Restaurant.find(params[:restaurant_id])
      @menus = @restaurant.menus.with_associations
    else
      @menus = Menu.with_associations
    end

    render_ok(@menus, include: :menu_items)
  end

  def show
    render_ok(@menu, include: [ :menu_items, :restaurant ])
  end

  def create
    @menu = @restaurant.menus.new(menu_params)

    if @menu.save
      render_created(@menu)
    else
      render_errors(@menu)
    end
  end

  def update
    if @menu.update(menu_params)
      render_ok(@menu)
    else
      render_errors(@menu)
    end
  end

  def destroy
    @menu.destroy
    render_no_content
  end

  def add_menu_item
    result = MenuManagementService.add_menu_item(@menu, params[:menu_item_id])

    if result.success
      render_ok({
        message: "Menu item added successfully",
        menu: result.data[:menu],
        menu_item: result.data[:menu_item]
      })
    else
      render_service_error(result, status: result.status || :unprocessable_entity)
    end
  end

  def remove_menu_item
    result = MenuManagementService.remove_menu_item(@menu, params[:menu_item_id])

    if result.success
      render_ok({
        message: "Menu item removed successfully",
        menu: result.data[:menu]
      })
    else
      render_service_error(result, status: result.status || :unprocessable_entity)
    end
  end

  private

  def menu_params
    permitted = [ :name, :description, :active, categories: [] ]
    params.require(:menu).permit(permitted)
  end
end
