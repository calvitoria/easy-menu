class RestaurantsController < ApplicationController
  include LoadResource

  load_resource :restaurant, only: [ :show, :update, :destroy ]

  def index
    @restaurants = Restaurant.includes(menus: :menu_items).all
    render json: @restaurants, include: { menus: { include: :menu_items } }
  end

  def show
    render json: @restaurant, include: { menus: { include: :menu_items } }
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    if @restaurant.save
      render json: @restaurant, status: :created
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(restaurant_params)
      render json: @restaurant
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @restaurant.destroy
    head :no_content
  end

  def restaurant_params
    params.require(:restaurant).permit(
      :name,
      :email,
      :description,
      :address,
      :active
    )
  end
end
