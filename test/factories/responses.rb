FactoryBot.define do
  factory :response do
    llm_job
    response { Faker::Lorem.paragraphs(number: 3).join("\n\n") }

    trait :with_ratings do
      after(:create) do |response|
        create_list(:rating, 2, response: response)
      end
    end

    trait :short_response do
      response { Faker::Lorem.paragraph }
    end

    trait :long_response do
      response { Faker::Lorem.paragraphs(number: 10).join("\n\n") }
    end

    factory :response_with_ratings, traits: [ :with_ratings ]
    factory :short_response_with_ratings, traits: [ :short_response, :with_ratings ]
    factory :long_response_with_ratings, traits: [ :long_response, :with_ratings ]
  end
end
