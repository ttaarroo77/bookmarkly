FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
  end
  
  factory :prompt do
    title { Faker::Lorem.sentence }
    url { Faker::Internet.url }
    tags { [Faker::Lorem.word, Faker::Lorem.word] }
    association :user
  end
end