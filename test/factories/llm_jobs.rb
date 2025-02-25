FactoryBot.define do
  factory :llm_job do
    prompt
    llm
    priority { Faker::Number.between(from: 0, to: 10) }
    sequence(:position)
    status { "queued" }
    response_time_ms { nil }
    response { nil }

    trait :with_response do
      status { "completed" }
      response { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
      response_time_ms { Faker::Number.between(from: 100, to: 5000) }
    end

    trait :processing do
      status { "processing" }
    end

    trait :completed do
      status { "completed" }
      response_time_ms { Faker::Number.between(from: 100, to: 5000) }
      response { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    end

    trait :failed do
      status { "failed" }
      response_time_ms { Faker::Number.between(from: 100, to: 5000) }
    end

    trait :high_priority do
      priority { 10 }
      position { 1 }
    end

    trait :fast_response do
      response_time_ms { Faker::Number.between(from: 100, to: 1000) }
    end

    trait :slow_response do
      response_time_ms { Faker::Number.between(from: 4000, to: 5000) }
    end

    trait :short_response do
      response { Faker::Lorem.paragraph }
    end

    trait :long_response do
      response { Faker::Lorem.paragraphs(number: 10).join("\n\n") }
    end

    trait :with_ratings do
      after(:create) do |job|
        create_list(:rating, 2, llm_job: job)
      end
    end

    factory :processing_job, traits: [ :processing ]
    factory :completed_job, traits: [ :completed ]
    factory :failed_job, traits: [ :failed ]
    factory :high_priority_job, traits: [ :high_priority ]
    factory :fast_completed_job, traits: [ :completed, :fast_response ]
    factory :slow_completed_job, traits: [ :completed, :slow_response ]
    factory :completed_job_with_ratings, traits: [ :completed, :with_ratings ]
    factory :short_response_job, traits: [ :completed, :short_response ]
    factory :long_response_job, traits: [ :completed, :long_response ]
  end
end
