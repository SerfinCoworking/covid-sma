Rails.application.routes.draw do
  resources :epidemic_sheets
  # custom error routes
  match '/404' => 'errors#not_found', :via => :all
  match '/406' => 'errors#not_acceptable', :via => :all
  match '/422' => 'errors#unprocessable_entity', :via => :all
  match '/500' => 'errors#internal_server_error', :via => :all

  resources :permission_requests do
    member do
      get "end"
    end
  end

  post 'auth/login', to: 'authentication#authenticate'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Notifications::Engine => "/notifications"

  # Con esta ruta marcamos una notificacion como leida
  post '/notifications/:id/set-as-read',
    to: 'notifications/notifications#set_as_read',
    as: 'notifications_set_as_read'

  # devise_for :users, :controllers => { registrations: 'registrations' }
  devise_for :users, :skip => [:registrations], :controllers => {:sessions => :sessions}

  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :users_admin, :controller => 'users', only: [:index, :update, :show] do
    member do
      get "change_sector"
      get "edit_permissions"
      put "update_permissions"
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :patients
      get 'insurances/get_by_dni/:dni', to: 'insurances#get_by_dni'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :profiles, only: [ :edit, :update, :show ]

  resources :establishments do
    member do
      get "delete"
    end
    collection do
      get "search_by_name"
    end
  end

  resources :sectors do
    member do
      get "delete"
    end

    collection do
      get "with_establishment_id"
    end
  end

  resources :patients do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "search"
      get "get_by_dni_and_fullname"
      get "get_by_dni"
      get "get_by_fullname"
    end
  end

  resources :professionals do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "doctors"
      get "get_by_enrollment_and_fullname"
    end
  end
end
