FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    gender { %w[male female other].sample }
    lang { "en" }

    trait :german do
      lang { "de" }
    end
  end
end
