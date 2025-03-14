# spec/support/devise.rb - Deviseのテスト設定

require 'devise'
require 'warden'

# Deviseのテスト設定
RSpec.configure do |config|
  # Deviseのテストヘルパーを各種テストタイプに追加
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :feature
  
  # テスト全体の前にWardenのテストモードを有効化
  config.before(:suite) do
    Warden.test_mode!
    puts "Warden test mode enabled in devise.rb"
  end
  
  # 各テスト後にWardenをリセット
  config.after(:each) do
    Warden.test_reset! if defined?(Warden)
  end
end