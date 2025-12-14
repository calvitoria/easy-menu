Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "menus#index"
  resources :menus do
    resources :menu_items, shallow: true
  end

  match "*unmatched", to: "application#route_not_found", via: :all
end
