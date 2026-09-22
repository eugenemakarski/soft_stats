Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "teams#index"

  resources :teams do
    # Players belong to a team, so they're always reached through one.
    resources :players, shallow: true
    # as: :members so the helpers are team_members_path / team_member_path
    resources :team_memberships, path: "members", as: :members, only: [ :index, :create, :update, :destroy ]
    resources :seasons, shallow: true, only: [ :new, :create, :show ] do
      member do
        get :stats
      end
      resources :player_teams, shallow: true
      resources :games, shallow: true, only: [ :new, :create, :show ] do
        member do
          patch :start
          post :generate_lineup
        end
        resources :game_rosters, shallow: true, only: [ :index, :create ]
        resources :plate_appearances, only: [ :new, :create, :edit, :update ]
        resources :inning_scores, only: [ :new, :create ]
      end
    end
  end

  # player index is team roster
  # season show is games list

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
