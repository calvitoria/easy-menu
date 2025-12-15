class MenusController < ApplicationController
  include ValidatesCategoriesParam

  before_action :set_menu, only: [ :show, :update, :destroy, :add_menu_item, :remove_menu_item ]
  before_action :set_restaurant, only: [ :index, :create ]
  before_action :validate_categories_param, only: [ :create, :update ]

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

    if @menu.menu_items << menu_item
      render json: {
        message: "Menu item added successfully",
        menu: @menu,
        menu_item: menu_item
      }
    else
      render json: { errors: "Could not add menu item to menu" }, status: :unprocessable_entity
    end
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

  private

  def set_menu
    @menu = Menu.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu not found" }, status: :not_found
  end

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Restaurant not found" }, status: :not_found
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
