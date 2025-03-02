FactoryBot.define do
  factory :system_config do
    sequence(:key) { |n| "config_key_#{n}" }
    value { "config_value" }
  end
end
