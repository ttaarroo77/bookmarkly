# spec/support/controller_helpers.rb - コントローラーテスト用ヘルパー

module ControllerHelpers
  # Deviseのマッピングをセットアップ
  def setup_devise_mapping
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  # ユーザーとしてログイン（モック版）
  def login_as_user(user = nil)
    user ||= FactoryBot.create(:user)
    setup_devise_mapping
    sign_in user
    user
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end 