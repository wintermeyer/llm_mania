FactoryBot.define do
  factory :llm do
    sequence(:name) { |n| "#{Faker::Company.name} LLM #{n}" }
    sequence(:ollama_model) { |n| "#{%w[llama2 codellama mistral mixtral phi neural-chat stable-code vicuna].sample}:#{n}" }
    size { Faker::Number.between(from: 3, to: 20) }
    creator { Faker::Company.name }
    active { true }
  end
end
