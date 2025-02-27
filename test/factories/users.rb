FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    gender { %w[male female other].sample }
    lang { "en" }  # Default to English
    active { true }

    # Confirmable
    confirmed_at { Time.current }
    confirmation_sent_at { Time.current - 1.day }

    trait :admin do
      after(:create) do |user|
        admin_role = create(:role, name: "admin")
        user.update!(current_role: admin_role)
        create(:user_role_association, user: user, role: admin_role)
      end
    end

    trait :inactive do
      active { false }
    end

    trait :with_prompts do
      after(:create) do |user|
        create_list(:prompt, 3, user: user)
      end
    end

    trait :german do
      lang { "de" }
      after(:build) do |user|
        # Use German Faker data for consistency
        Faker::Config.locale = "de"
        user.first_name = Faker::Name.first_name
        user.last_name = Faker::Name.last_name
        Faker::Config.locale = "en"  # Reset to English
      end
    end

    factory :admin_user, traits: [ :admin ]
    factory :inactive_user, traits: [ :inactive ]
    factory :user_with_prompts, traits: [ :with_prompts ]
    factory :german_user, traits: [ :german ]
  end
end
