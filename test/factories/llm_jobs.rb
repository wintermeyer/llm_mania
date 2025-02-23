FactoryBot.define do
  factory :llm_job do
    prompt
    llm
    priority { Faker::Number.between(from: 0, to: 10) }
    sequence(:position)
    status { "queued" }
    response_time_ms { nil }

    trait :with_response do
      after(:create) do |job|
        create(:response, llm_job: job)
      end
    end

    trait :processing do
      status { "processing" }
    end

    trait :completed do
      status { "completed" }
      response_time_ms { Faker::Number.between(from: 100, to: 5000) }
      after(:create) do |job|
        create(:response, llm_job: job)
      end
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

    factory :processing_job, traits: [ :processing ]
    factory :completed_job, traits: [ :completed ]
    factory :failed_job, traits: [ :failed ]
    factory :high_priority_job, traits: [ :high_priority ]
    factory :fast_completed_job, traits: [ :completed, :fast_response ]
    factory :slow_completed_job, traits: [ :completed, :slow_response ]
  end
end
