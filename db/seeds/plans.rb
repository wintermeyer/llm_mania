# Clear existing plans
Plan.destroy_all

# Create plans
[
  {
    name: "Free Plan",
    price: 0,
    is_active: true,
    description: "Have access to the basic LLM models."
  },
  {
    name: "Pro Plan",
    price: 9.99,
    is_active: true,
    description: "Have access to all active LLM models."
  },
  {
    name: "Fast Track Plan",
    price: 19.99,
    is_active: true,
    description: "Have access to all active LLM models and by pass the queue. Get your requests done faster."
  }
].each do |plan_data|
  Plan.create!(plan_data)
end

puts "Created #{Plan.count} plans"
