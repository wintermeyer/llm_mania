FactoryBot.define do
  factory :subscription do
    sequence(:name) { |n| "#{Faker::Subscription.plan} #{n}" }
    description { Faker::Lorem.paragraph }
    max_llm_requests_per_day { Faker::Number.between(from: 10, to: 1000) }
    priority { Faker::Number.between(from: 0, to: 3) }
    max_prompt_length { Faker::Number.between(from: 100, to: 2000) }
    price_cents { Faker::Number.between(from: 0, to: 10000) }
    private_prompts_allowed { false }
    active { true }

    trait :with_llms do
      after(:create) do |subscription|
        create_list(:subscription_llm, 2, subscription: subscription)
      end
    end

    trait :private_prompts do
      private_prompts_allowed { true }
    end

    trait :inactive do
      active { false }
    end

    trait :high_priority do
      priority { 10 }
      max_llm_requests_per_day { 1000 }
      max_prompt_length { 2000 }
      private_prompts_allowed { true }
    end

    factory :premium_subscription, traits: [ :high_priority, :private_prompts ]
    factory :inactive_subscription, traits: [ :inactive ]
    factory :subscription_with_llms, traits: [ :with_llms ]
  end
end
