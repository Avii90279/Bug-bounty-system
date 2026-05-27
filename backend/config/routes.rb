require "sidekiq/web"

Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      post "auth/google", to: "auth#google"
      get "auth/me", to: "auth#me"
      post "auth/refresh", to: "auth#refresh"

      resources :challenges, only: [:index, :show, :create] do
        member do
          post :submit
          post :hint
          get :analytics
        end
        collection do
          post :generate
        end
      end

      resources :submissions, only: [:index, :show]
      resources :leaderboard, only: [:index]
      resources :badges, only: [:index]
      resources :users, only: [:show, :update]

      resources :rooms, only: [:index, :show, :create] do
        member do
          post :join
          post :leave
          post :start
        end
      end

      namespace :admin do
        get "dashboard", to: "dashboard#index"
        resources :challenges
        resources :users, only: [:index, :show, :update]
        get "analytics", to: "analytics#index"
      end

      namespace :blockchain do
        post "connect_wallet", to: "wallets#connect"
        get "wallet", to: "wallets#show"
        post "mint_badge", to: "nft_badges#mint"
        get "nft_badges", to: "nft_badges#index"
      end
    end
  end

  get "health", to: proc { [200, {}, ["OK"]] }
end
