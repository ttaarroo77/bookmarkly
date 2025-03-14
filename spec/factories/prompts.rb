# spec/factories/prompts.rb - プロンプトのファクトリー定義

FactoryBot.define do
  # 既存のpromptファクトリが定義されていないことを確認してから定義する
  unless FactoryBot.factories.registered?(:prompt)
    factory :prompt do
      sequence(:title) { |n| "プロンプトタイトル#{n}" }
      content { "これはテスト用のプロンプト内容です。" }
      association :user
    end
  end
end