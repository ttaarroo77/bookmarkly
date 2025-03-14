# spec/controllers/simple_devise_test.rb

require 'rails_helper'

# 最もシンプルなDeviseテスト
RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: "Hello, #{current_user.try(:email) || 'Guest'}"
    end
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  describe "Devise basic test" do
    it "allows a guest user" do
      get :index
      expect(response.body).to eq("Hello, Guest")
    end

    it "allows a signed in user" do
      # 明示的にマッピングを設定
      @request.env["devise.mapping"] = Devise.mappings[:user]
      
      # ユーザーを作成
      user = User.create!(email: 'test@example.com', password: 'password123')
      
      # 手動でログイン
      sign_in user
      
      get :index
      expect(response.body).to eq("Hello, #{user.email}")
    end
  end
end 