class MenuItemsController < ApplicationController
  include ValidatesCategoriesParam

  before_action :set_menu, only: [ :index, :create ]
  before_action :set_menu_item, only: [ :show, :update, :destroy ]
  before_action :validate_categories_param, only: [ :create, :update ]

  def index
    render json: @menu.menu_items
  end

  def show
    render json: @menu_item
  end

  def create
    @menu_item = @menu.menu_items.new(menu_item_params)

    if @menu_item.save
      render json: @menu_item, status: :created
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
  end

  private

  def set_menu
    @menu = Menu.find(params[:menu_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu not found" }, status: :not_found
  end

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Menu item not found" }, status: :not_found
  end

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
