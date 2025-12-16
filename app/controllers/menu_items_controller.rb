class MenuItemsController < ApplicationController
  include LoadResource
  include ValidateArrayParam

  load_resource :menu, param: :menu_id, only: [ :index, :create ]
  load_resource :menu_item, only: [ :show, :update, :destroy ]

  before_action only: [ :create, :update ] do
    validate_array_of_strings :categories, scope: :menu_item
    validate_array_of_ids :menu_ids if params.key?(:menu_ids)
  end

  def index
    @menu_items = @menu ? @menu.menu_items : MenuItem.all
    render json: @menu_items, include: @menu ? nil : :menus
  end

  def show
    render json: @menu_item, include: :menus
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)

    if @menu
      @menu_item.menus << @menu
    end

    if params[:menu_ids].present?
      begin
        @menu_item.menu_ids = Array(params[:menu_ids])
      rescue ActiveRecord::RecordNotFound => e
        return render json: { error: "One or more menus not found" }, status: :unprocessable_entity
      end
    end

    if @menu_item.save
      render json: @menu_item, include: :menus, status: :created
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if params.key?(:menu_ids)
      begin
        menu_ids = Array(params[:menu_ids])
        if menu_ids.empty?
          @menu_item.menu_item_menus.destroy_all
        else
          @menu_item.menu_ids = menu_ids
        end
      rescue ActiveRecord::RecordNotFound => e
        return render json: { error: "One or more menus not found" }, status: :unprocessable_entity
      end
    end

    if @menu_item.update(menu_item_params.except(:menu_ids))
      render json: @menu_item, include: :menus
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    head :no_content
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
