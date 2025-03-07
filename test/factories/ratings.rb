FactoryBot.define do
  factory :rating do
    llm_job { create(:completed_job) }
    user
    score { Faker::Number.between(from: 1, to: 5) }
    comment { Faker::Lorem.paragraph }

    trait :low_rating do
      score { Faker::Number.between(from: 1, to: 2) }
      comment { "Not satisfied with the response" }
    end

    trait :high_rating do
      score { Faker::Number.between(from: 4, to: 5) }
      comment { "Excellent response!" }
    end

    factory :low_rating_review, traits: [ :low_rating ]
    factory :high_rating_review, traits: [ :high_rating ]
  end
end
