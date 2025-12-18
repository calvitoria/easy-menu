class MenuItemsController < ApplicationController
  load_resource :menu, param: :menu_id, only: [ :index, :new, :create ]
  load_resource :menu_item, only: [ :show, :edit, :update, :destroy ]

  before_action only: [ :create, :update ] do
    if params[:menu_item] && params[:menu_item][:categories].is_a?(String)
      params[:menu_item][:categories] = params[:menu_item][:categories].split(",").map(&:strip)
    end
    validate_array_of_strings :categories, scope: :menu_item
    if params.key?(:menu_ids)
      params[:menu_ids] = params[:menu_ids].split(",").map(&:strip) if params[:menu_ids].is_a?(String)
      validate_array_of_ids :menu_ids
    end
  end

  def index
    if @menu
      @menu_items = @menu.menu_items.with_associations
    else
      @menu_items = MenuItem.with_associations
    end

    respond_to do |format|
      format.html
      format.json { render_ok(@menu_items, include: :menus) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render_ok(@menu_item, include: :menus) }
    end
  end

  def new
    @menu_item = @menu ? @menu.menu_items.new : MenuItem.new
  end

  def edit
    # Handled by load_resource
  end

  def create
    @menu_item = MenuItem.new

    result = MenuItemAssignmentService.assign_menus_to_item(
      menu_item: @menu_item,
      menu_ids_param: params[:menu_ids],
      menu_from_route: @menu,
      menu_item_attributes: menu_item_params
    )

    respond_to do |format|
      if result.success
        format.html { redirect_to menu_item_path(result.data[:menu_item]), notice: "Menu item was successfully created." }
        format.json { render_created(result.data[:menu_item], include: :menus) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render_service_error(result) }
      end
    end
  end

  def update
    result = MenuItemAssignmentService.assign_menus_to_item(
      menu_item: @menu_item,
      menu_ids_param: params[:menu_ids],
      menu_from_route: nil,
      menu_item_attributes: menu_item_params
    )

    respond_to do |format|
      if result.success
        format.html { redirect_to menu_item_path(@menu_item), notice: "Menu item was successfully updated." }
        format.json { render_ok(@menu_item, include: :menus) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render_service_error(result) }
      end
    end
  end

  def destroy
    @menu_item.destroy

    respond_to do |format|
      format.html { redirect_to menu_items_url, notice: "Menu item was successfully destroyed." }
      format.json { render_no_content }
    end
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
