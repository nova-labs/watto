Rails.application.routes.draw do


  namespace :wild_apricot do
    post 'webhook', to: "webhook#create"
  end

  resources :events, only: [:index, :show, :update]
  resources :users, only: [:index, :show, :update] do
    resource :signoffs, only: [:edit, :update], controller: "user_signoffs"
    resource :onboarding
  end
  resource :batch_update_tool do
    get 'search'
    get 'contact'
  end

  get 'formbot/:event', to: 'formbot#redirect', as: :formbot

  # Admin Section
  get 'admin', to: 'admin/welcome#show'
  namespace :admin do
    resource :sync
    resources :fields, only: [:index, :show]
    resources :users, only: [:index, :show] do
      resources :fields, :show, controller: "user_fields"
    end
  end

  # Defines the root path route ("/")
  root 'welcome#index'

  # Routes for OmniAuth
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/callback/:provider', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: :logout
end
