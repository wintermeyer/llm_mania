FactoryBot.define do
  factory :prompt do
    association :user
    content { Faker::Lorem.paragraph }
    private { false }
    status { "waiting" }
    hidden { false }
    flagged { false }

    trait :private do
      private { true }
    end

    trait :hidden do
      hidden { true }
    end

    trait :flagged do
      flagged { true }
    end

    trait :in_queue do
      status { "in_queue" }
    end

    trait :processing do
      status { "processing" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :failed do
      status { "failed" }
    end

    trait :with_jobs do
      after(:create) do |prompt|
        create_list(:llm_job, 4, prompt: prompt)
      end
    end

    factory :private_prompt, traits: [ :private ]
    factory :hidden_prompt, traits: [ :hidden ]
    factory :flagged_prompt, traits: [ :flagged ]
    factory :prompt_with_jobs, traits: [ :with_jobs ]
  end
end
