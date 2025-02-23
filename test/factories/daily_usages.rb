FactoryBot.define do
  factory :daily_usage do
    user
    date { Date.current }
    llm_requests { Faker::Number.between(from: 0, to: 100) }

    trait :high_usage do
      llm_requests { Faker::Number.between(from: 900, to: 1000) }
    end

    trait :no_usage do
      llm_requests { 0 }
    end

    trait :past_date do
      date { Faker::Date.backward(days: 30) }
    end

    trait :future_date do
      date { Faker::Date.forward(days: 30) }
    end

    factory :high_usage_day, traits: [ :high_usage ]
    factory :no_usage_day, traits: [ :no_usage ]
    factory :past_high_usage_day, traits: [ :high_usage, :past_date ]
    factory :past_no_usage_day, traits: [ :no_usage, :past_date ]
  end
end
