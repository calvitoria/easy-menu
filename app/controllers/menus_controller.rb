class MenusController < ApplicationController
  include LoadResource
  include ValidateArrayParam

  load_resource :menu, only: [ :show, :update, :destroy, :add_menu_item, :remove_menu_item ]
  load_resource :restaurant, param: :restaurant_id, only: [ :index, :create ]

  before_action only: [ :create, :update ] do
    validate_array_of_strings :categories, scope: :menu
  end

  def index
    @menus = @restaurant.menus.includes(:menu_items)
    render json: @menus, include: :menu_items
  end

  def show
    render json: @menu, include: [ :menu_items, :restaurant ]
  end

  def create
    @menu = @restaurant.menus.new(menu_params)

    if @menu.save
      render json: @menu, status: :created
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(menu_params)
      render json: @menu
    else
      render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy
    head :no_content
  end

  def add_menu_item
    menu_item = MenuItem.find(params[:menu_item_id])

    if @menu.menu_items.exists?(menu_item.id)
      render json: { errors: "Could not add menu item to menu" },
             status: :unprocessable_entity
      return
    end

    @menu.menu_items << menu_item

    render json: {
      message: "Menu item added successfully",
      menu: @menu,
      menu_item: menu_item
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu item not found" }, status: :not_found
  end

  def remove_menu_item
    menu_item = MenuItem.find(params[:menu_item_id])

    if @menu.menu_items.delete(menu_item)
      render json: {
        message: "Menu item removed successfully",
        menu: @menu
      }
    else
      render json: { errors: "Could not remove menu item from menu" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu item not found" }, status: :not_found
  end

  def menu_params
    params.require(:menu).permit(
      :name,
      :description,
      :active,
      :restaurant_id,
      categories: []
    )
  end
end
