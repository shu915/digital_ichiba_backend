Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    resource :login, only: [ :create ]
    resource :shop, only: [ :show, :create, :update ], controller: :shop
    resources :shops, only: [ :index, :show ]
    resources :products, only: [ :create, :index, :show, :update, :destroy ]
    resource :stripe_accounts, only: [ :create ]
    resource :stripe_webhooks, only: [ :create ]
    resource :stripe_checkouts, only: [ :create ]
  end
end
