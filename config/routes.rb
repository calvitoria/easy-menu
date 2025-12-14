Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "restaurants#index"

  resources :restaurants do
    resources :menus, shallow: true do
      resources :menu_items, shallow: true
    end
  end

  match "*unmatched", to: "application#route_not_found", via: :all
end
