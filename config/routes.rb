Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "restaurants#index"

  resources :restaurants do
    resources :menus, shallow: true do
      resources :menu_items, shallow: true, only: [ :index, :create ]
    end
  end

  resources :menu_items, except: [ :new, :edit ]

  resources :menus, except: [ :new, :edit ] do
    member do
      post :add_menu_item
      delete :remove_menu_item
    end
  end

  match "*unmatched", to: "application#route_not_found", via: :all
end
