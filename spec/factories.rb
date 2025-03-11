FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end

  factory :prompt do
    sequence(:title) { |n| "プロンプト#{n}" }
    sequence(:url) { |n| "https://example.com/prompt#{n}" }
    user
  end

  factory :tag do
    sequence(:name) { |n| "タグ#{n}" }
    user
  end
end 