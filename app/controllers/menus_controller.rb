class MenusController < ApplicationController
  load_resource :restaurant, param: :restaurant_id, only: [ :index, :new, :create ]
  load_resource :menu, only: [ :show, :edit, :update, :destroy, :add_menu_item, :remove_menu_item ]

  before_action only: [ :create, :update ] do
    if params[:menu][:categories].is_a?(String)
      params[:menu][:categories] = params[:menu][:categories].split(",").map(&:strip)
    end
    validate_array_of_strings :categories, scope: :menu
  end

  def index
    @menus = if @restaurant
               @restaurant.menus.with_associations
    else
               Menu.with_associations
    end

    respond_to do |format|
      format.html
      format.json { render json: @menus, include: :menu_items }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @menu, include: [ :menu_items, :restaurant ] }
    end
  end

  def new
    @menu = @restaurant ? @restaurant.menus.new : Menu.new
  end

  def edit
    # Handled by load_resource
  end

  def create
    @menu = @restaurant ? @restaurant.menus.new(menu_params) : Menu.new(menu_params)

    respond_to do |format|
      if @menu.save
        format.html { redirect_to @menu, notice: "Menu was successfully created." }
        format.json { render json: @menu, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @menu.update(menu_params)
        format.html { redirect_to @menu, notice: "Menu was successfully updated." }
        format.json { render json: @menu }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @menu.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    restaurant = @menu.restaurant
    @menu.destroy

    respond_to do |format|
      format.html { redirect_to restaurant ? restaurant_menus_url(restaurant) : menus_url, notice: "Menu was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_menu_item
    result = MenuManagementService.add_menu_item(@menu, params[:menu_item_id])

    respond_to do |format|
      if result.success
        format.html { redirect_to @menu, notice: "Menu item added successfully." }
        format.json { render json: { message: "Menu item added successfully", menu: result.data[:menu], menu_item: result.data[:menu_item] } }
      else
        format.html { redirect_to @menu, alert: result.errors.join(", ") }
        format.json { render json: { errors: result.errors }, status: result.status || :unprocessable_entity }
      end
    end
  end

  def remove_menu_item
    result = MenuManagementService.remove_menu_item(@menu, params[:menu_item_id])

    respond_to do |format|
      if result.success
        format.html { redirect_to @menu, notice: "Menu item removed successfully." }
        format.json { render json: { message: "Menu item removed successfully", menu: result.data[:menu] } }
      else
        format.html { redirect_to @menu, alert: result.errors.join(", ") }
        format.json { render json: { errors: result.errors }, status: result.status || :unprocessable_entity }
      end
    end
  end

  private

  def menu_params
    permitted = [ :name, :description, :active, categories: [] ]
    params.require(:menu).permit(permitted)
  end
end
