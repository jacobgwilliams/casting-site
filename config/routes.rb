Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource :session, only: %i[show create update destroy]
      resource :actor_profile, only: %i[show update]
      resource :casting_professional_profile, only: %i[show update]
      resource :representative_profile, only: %i[show update]
      resources :registrations, only: %i[create]
      resources :organizations, only: %i[index show create update]
      resources :projects, only: %i[index show create update] do
        resources :breakdowns, only: %i[create], shallow: false
      end
      resources :breakdowns, only: %i[index show update]
      resources :skills, only: %i[index]
    end
  end
end
