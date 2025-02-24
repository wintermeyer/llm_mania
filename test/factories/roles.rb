FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { Faker::Lorem.sentence }
    active { true }

    trait :admin do
      name { "admin" }
      description { "Administrator role with full access" }
    end

    trait :user do
      name { "user" }
      description { "Regular user role with standard access" }
    end

    trait :inactive do
      active { false }
    end

    factory :admin_role, traits: [ :admin ]
    factory :user_role, traits: [ :user ]
    factory :inactive_role, traits: [ :inactive ]
  end
end
