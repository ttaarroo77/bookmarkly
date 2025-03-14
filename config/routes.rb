Rails.application.routes.draw do
  # Deviseのルート設定を最初に配置
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  
  # マイページのルート追加
  get 'mypage', to: 'users#show', as: :mypage
  
  # プロンプトリソース
  resources :prompts do
    member do
      post :generate_description
      post :generate_tag_suggestions
    end
    collection do
      get :search
    end
  end
  
  # タグリソース
  resources :tags, only: [:index, :show, :destroy]
  
  # ユーザー関連
  resources :users, only: [:show, :edit, :update]
  
  # ルートパス
  root 'prompts#index'
  
  # その他のルート
  # ...
end
