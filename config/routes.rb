Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "restaurants#index"

  resources :restaurants do
    resources :menus, shallow: true do
      resources :menu_items, shallow: true, only: [ :index, :new, :create ]
    end
  end

  resources :menu_items, except: []

  resources :menus, except: [] do
    member do
      post :add_menu_item
      delete :remove_menu_item
    end
  end

  resources :imports, only: [ :index, :show ]

  get "imports/new/restaurants", to: "imports#new", as: :new_import_restaurants
  post "imports/restaurants", to: "imports#create", as: :import_restaurants

  match "*unmatched", to: "application#route_not_found", via: :all
end
