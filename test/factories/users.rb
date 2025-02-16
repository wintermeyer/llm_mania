FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    gender { User.genders.keys.sample }
    role { :user }
    lang { :en }
    active { true }

    trait :admin do
      role { :admin }
    end

    trait :inactive do
      active { false }
    end

    trait :german do
      lang { :de }
    end
  end
end
