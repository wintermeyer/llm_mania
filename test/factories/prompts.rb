FactoryBot.define do
  factory :prompt do
    user
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    private { false }
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
