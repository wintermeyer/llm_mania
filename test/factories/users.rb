FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password_digest { Faker::Crypto.md5 }
    gender { %w[male female other].sample }
    role { "user" }
    lang { %w[en de].sample }
    active { true }

    trait :admin do
      role { "admin" }
    end

    trait :inactive do
      active { false }
    end

    trait :with_prompts do
      after(:create) do |user|
        create_list(:prompt, 3, user: user)
      end
    end 

    factory :admin_user, traits: [ :admin ]
    factory :inactive_user, traits: [ :inactive ]
    factory :user_with_prompts, traits: [ :with_prompts ]
  end
end
