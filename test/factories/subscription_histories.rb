FactoryBot.define do
  factory :subscription_history do
    user
    subscription
    start_date { Time.current }
    end_date { 1.month.from_now }

    trait :expired do
      start_date { 2.months.ago }
      end_date { 1.month.ago }
    end

    factory :expired_subscription_history, traits: [ :expired ]
  end
end
