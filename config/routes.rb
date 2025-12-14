Rails.application.routes.draw do
  get "restaurants/index"
  get "restaurants/show"
  get "restaurants/create"
  get "restaurants/update"
  get "restaurants/destroy"
  get "up" => "rails/health#show", as: :rails_health_check

  root "restaurants#index"

  resources :restaurants do
    resources :menus, shallow: true do
      resources :menu_items, shallow: true
    end
  end

  resources :menus do
    resources :menu_items, shallow: true
  end

  match "*unmatched", to: "application#route_not_found", via: :all
end
