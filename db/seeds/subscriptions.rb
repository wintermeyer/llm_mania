# Clear existing subscriptions
Subscription.destroy_all

# Get existing LLM models
small_models = Llm.where("size <= ?", 7).to_a
all_models = Llm.all.to_a

puts "Found #{small_models.count} small models (≤7B parameters) and #{all_models.count} total models"

# Create Basic (Free) subscription
basic = Subscription.create!(
  name: "Free",
  description: "Access to small language models for basic tasks.",
  max_llm_requests_per_day: 10,
  priority: 0,
  max_prompt_length: 250,
  price_cents: 0,
  private_prompts_allowed: false,
  active: true
)

# Associate Basic subscription with all small models (7B or less)
basic.llms << small_models
puts "Basic subscription has access to: #{basic.llms.order(:size).pluck(:name, :size).map { |name, size| "#{name} (#{size}B)" }.join(', ')}"

# Create Pro subscription
pro = Subscription.create!(
  name: "Pro",
  description: "Access to all language models with generous limits",
  max_llm_requests_per_day: 150,
  priority: 1,
  max_prompt_length: 1500,
  price_cents: 1000,
  private_prompts_allowed: true,
  active: true
)

# Associate Pro subscription with all models
pro.llms << all_models
puts "Pro subscription has access to: #{pro.llms.order(:size).pluck(:name, :size).map { |name, size| "#{name} (#{size}B)" }.join(', ')}"

# Create Fasttrack subscription
fasttrack = Subscription.create!(
  name: "FastTrack",
  description: "Priority access to all models with highest limits",
  max_llm_requests_per_day: 300,
  priority: 2,
  max_prompt_length: 5000,
  price_cents: 2000,
  private_prompts_allowed: true,
  active: true
)

# Associate FastTrack subscription with all models
fasttrack.llms << all_models
puts "FastTrack subscription has access to: #{fasttrack.llms.order(:size).pluck(:name, :size).map { |name, size| "#{name} (#{size}B)" }.join(', ')}"

puts "\nCreated #{Subscription.count} subscriptions with access to #{Llm.count} LLM models"
