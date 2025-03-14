# spec/factories/tags.rb - タグのファクトリー定義

FactoryBot.define do
  # 重複定義を避けるためのチェック
  unless FactoryBot.factories.registered?(:tag)
    factory :tag do
      sequence(:name) { |n| "tag#{n}" }
      association :user
    end
  end
end