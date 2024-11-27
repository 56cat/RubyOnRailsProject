require 'sidekiq'
require 'sidekiq/web'
Rails.application.routes.draw do

  devise_for :users, controllers: {
    registrations: "login/registrations",
    sessions: "login/sessions"
  }
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
  root :to => "application#redirect_to_root"
  namespace :super_admin do
    root :to => "dashboard#index"
    get '/preview_pdf_file', to: 'dashboard#preview_pdf_file'
    resources :brands
    resources :products do
      collection do
        get :export
        post :export_csv_queue
        match :import, via: [:get, :post]
        get :download_template
      end
      member do
        post :add_to_cart
        delete :delete_image
      end
    end
    resources :csv_queues do
      collection do
        get '/export', to: 'csv_queues#export', defaults: { format: 'csv' }
      end
    end
    resources :users
    resources :promotions
    resources :deliveries, only: [:index, :show]
    resources :bills, only: [:index, :show]
  end
  namespace :supplier do
    root :to => "home#index"
    get '/preview_pdf_file', to: 'home#preview_pdf_file'

    resources :products, only: [:index, :show] do
      collection do
        get :export
        post :export_csv_queue
        match :search, :via => [:get, :post], :as => :search
      end
    end
    resources :inventory_products do
      collection do
        get :export
        get :download_template
        match :import, via: [:get, :post]
      end
    end
    resources :import_export_histories, only: [:index, :show, :new, :create]
    resources :export_notes do
      collection do
        get :download_template
        match :import, via: [:get, :post]
      end
    end
    resources :csv_queues do
      collection do
        get '/export', to: 'csv_queues#export', defaults: { format: 'csv' }
      end
    end
    resources :deliveries, only: [:index, :show] do
      member do
        post :change_status
      end
    end
    resources :conversations do
      member do
        get :get_messages
      end
      resource :messages
    end
  end
  namespace :user do
    root :to => "products#index"
    resources :products, only: [:index]
    resources :bills
    resources :line_items, only: [:index]
    resources :deliveries do
      member do
        post :change_status
      end
    end
    resources :conversations do
      member do
        get :get_messages
      end
      resource :messages
    end

  end
  resources :users

  match 'search', to: 'search#search', via: [:get, :post]
  match 'ajax_search', to: 'search#ajax_search', via: [:get, :post]


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
