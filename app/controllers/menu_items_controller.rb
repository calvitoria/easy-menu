class MenuItemsController < ApplicationController
  def index
    if params[:menu_id]
      menu = Menu.find(params[:menu_id])
      @menu_items = menu.menu_items
    else
      @menu_items = MenuItem.all
    end
    render json: @menu_items
  end

  def show
    menu_items = MenuItem.find(params[:id])
    render json: menu_items
  end

  def create
    menu_items = MenuItem.new(menu_items_params)
    if menu_items.save
      render json: menu_items, status: :created
    else
      render json: { errors: menu_items.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    menu_items = MenuItem.find(params[:id])
    if menu_items.update(menu_items_params)
      render json: menu_items
    else
      render json: { errors: menu_items.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    menu_items = MenuItem.find(params[:id])
    menu_items.destroy
    head :no_content
  end

  private

  def menu_items_params
    params.require(:menu_items).permit(:name, :menu_id)
  end
end
