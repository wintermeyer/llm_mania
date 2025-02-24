FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password_digest { Faker::Crypto.md5 }
    gender { %w[male female other].sample }
    lang { %w[en de].sample }
    active { true }
    association :current_role, factory: :role

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

    factory :admin_user, traits: [ :admin ]
    factory :inactive_user, traits: [ :inactive ]
    factory :user_with_prompts, traits: [ :with_prompts ]
  end
end
