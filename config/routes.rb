Rails.application.routes.draw do
  devise_for :users,
              controllers: {
                sessions: 'users/sessions',
                registrations: 'users/registrations'
              }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/member-data', to: 'members#show'
  
  resources :events do
    member do
      post 'join'
      delete 'leave'
    end
  end

  # Admin-only routes
  namespace :admin do
    resources :events do
      collection do
        delete :bulk_delete   # Bulk delete events
        patch :bulk_close     # Bulk close events
        get :search           # Search events
      end
    end

    resources :registrations do
      collection do
        delete :bulk_delete   # Bulk delete registrations
        get :search           # Search registrations
        get :export           # Export attendee list
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
