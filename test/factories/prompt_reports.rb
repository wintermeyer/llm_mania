FactoryBot.define do
  factory :prompt_report do
    prompt
    user
    reason { %w[spam offensive nsfw other].sample }

    trait :spam do
      reason { "spam" }
    end

    trait :offensive do
      reason { "offensive" }
    end

    trait :nsfw do
      reason { "nsfw" }
    end

    trait :other do
      reason { "other" }
    end

    factory :spam_report, traits: [ :spam ]
    factory :offensive_report, traits: [ :offensive ]
    factory :nsfw_report, traits: [ :nsfw ]
  end
end
