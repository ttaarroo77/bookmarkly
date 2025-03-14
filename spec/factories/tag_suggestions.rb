FactoryBot.define do
  unless FactoryBot.factories.registered?(:tag_suggestion)
    factory :tag_suggestion do
      sequence(:name) { |n| "suggestion#{n}" }
      count { 1 }
    end
  end
end 