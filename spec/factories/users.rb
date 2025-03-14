# spec/factories/users.rb - ユーザーのファクトリー定義

FactoryBot.define do
  # 重複定義を避けるためのチェック
  unless FactoryBot.factories.registered?(:user)
    factory :user do
      sequence(:email) { |n| "user#{n}@example.com" }
      password { "password123" }
      password_confirmation { "password123" }
    end
  end
end