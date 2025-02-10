# Clear existing plans
Plan.destroy_all

# Create plans
[
  {
    name: "Free",
    price: 0,
    is_active: true,
    description: "Access to the basic LLM models.",
    is_default: true,
    llm_model_ids: LlmModel.where(size: ..5000).pluck(:id) # Models under 5GB
  },
  {
    name: "Pro",
    price: 9.99,
    is_active: true,
    description: "Access to all active LLM models.",
    llm_model_ids: LlmModel.where(size: ..10000).pluck(:id) # Models under 10GB
  },
  {
    name: "Fast Track",
    price: 19.99,
    is_active: true,
    description: "Access to all active LLM models and by pass the queue. Get your requests done faster.",
    llm_model_ids: LlmModel.pluck(:id) # All models
  }
].each do |plan_data|
  Plan.create!(plan_data)
end

puts "Created #{Plan.count} plans"
