Rails.application.routes.draw do
  # No longer scoping routes with locale
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Defines the root path route ("/")
  root "pages#home"

  # Prompts
  resources :prompts, only: [:index, :new, :create, :show] do
    member do
      get :llm_jobs_status
    end
  end

  # Role switching (only available in development)
  resources :roles, only: [] do
    member do
      post :switch
    end
  end

  # Routes outside of locale scope
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
