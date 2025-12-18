class RestaurantsController < ApplicationController
  include LoadResource

  load_resource :restaurant, only: [ :show, :update, :destroy ]

  def index
    @restaurants = Restaurant.includes(menus: :menu_items).all

    respond_to do |format|
      format.html
      format.json { render json: @restaurants, include: { menus: { include: :menu_items } } }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @restaurant, include: { menus: { include: :menu_items } } }
    end
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    respond_to do |format|
      if @restaurant.save
        format.html { redirect_to @restaurant, notice: "Restaurant was successfully created." }
        format.json { render json: @restaurant, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @restaurant = Restaurant.find(params[:id])
  end

  def update
    if @restaurant.update(restaurant_params)
      respond_to do |format|
        format.html { redirect_to @restaurant, notice: "Restaurant was successfully updated." }
        format.json { render json: @restaurant }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @restaurant.destroy

    respond_to do |format|
      format.html { redirect_to restaurants_url, notice: "Restaurant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(
      :name,
      :email,
      :description,
      :address,
    )
  end
end
