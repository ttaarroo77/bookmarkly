Rails.application.routes.draw do
  devise_for :users
  
  # ルートパスの設定
  root 'prompts#index'
  
  # ブックマーク関連のルーティング
  resources :prompts do
    member do
      post 'apply_tag_suggestion/:suggestion_id', to: 'prompts#apply_tag_suggestion', as: :apply_tag_suggestion
    end
  end
  
  # ユーザー関連のルーティング
  get 'mypage', to: 'users#show', as: :mypage
  get 'mypage/edit', to: 'users#edit', as: :mypage_edit
  patch 'mypage', to: 'users#update'
  
  # タグ関連のルーティング（必要な場合）
  get 'prompts/tag/:tag', to: 'prompts#index', as: :prompts_by_tag

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
