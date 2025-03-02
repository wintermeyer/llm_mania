#!/usr/bin/env ruby
# This script tests the Ollama integration by creating a test prompt and processing it

# Find or create a test user
user = User.find_by(email: 'test@example.com')
unless user
  puts "Creating test user..."
  user = User.create!(
    email: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Test',
    last_name: 'User',
    gender: 'other',
    lang: 'en',
    active: true,
    confirmed_at: Time.current # Skip confirmation
  )
end

# Find the Ollama model
llm = Llm.find_by(name: 'Ollama Phi4')
unless llm
  puts "Creating Ollama Phi4 model..."
  llm = Llm.create!(
    name: 'Ollama Phi4',
    description: 'Phi4 model via Ollama',
    ollama_model: 'phi4',
    size: 10, # Size on a scale of 1-20
    active: true,
    category: 'local',
    creator: 'Microsoft'
  )
end

# Create a subscription for the user if they don't have one
subscription = Subscription.find_by(name: 'Test Subscription')
unless subscription
  puts "Creating test subscription..."
  subscription = Subscription.create!(
    name: 'Test Subscription',
    description: 'Test subscription for Ollama testing',
    price: 0,
    price_cents: 0,
    active: true,
    priority: 2,
    max_llm_requests_per_day: 100,
    max_prompt_length: 2000,
    private_prompts_allowed: true,
    daily_prompt_limit: 10
  )

  # Add the Ollama model to the subscription
  subscription.llms << llm unless subscription.llms.include?(llm)
end

# Create a subscription history for the user if they don't have one
unless user.current_subscription
  puts "Creating subscription history for user..."
  SubscriptionHistory.create!(
    user: user,
    subscription: subscription,
    start_date: 1.year.ago,
    end_date: 1.year.from_now
  )
end

# Create a prompt
puts "Creating test prompt..."
prompt = user.prompts.create!(
  content: 'Tell me a short joke',
  status: 'waiting',
  hidden: false,
  flagged: false,
  private: false
)

# The prompt's after_create callback should create LLM jobs
# But let's make sure we have one for our Ollama model
job = prompt.llm_jobs.find_by(llm: llm)
unless job
  puts "Creating LLM job for the prompt..."
  job = prompt.llm_jobs.create!(
    llm: llm,
    priority: 2,
    position: 0,
    status: 'queued'
  )
end

# Process the job
puts "Processing the job..."
ProcessLlmJob.perform_now(job.id)

# Check the result
job.reload
puts "\n\nPrompt: #{prompt.content}"
puts "\nResponse from #{llm.name}:"
puts job.response
puts "\nStatus: #{job.status}"
puts "Response time: #{job.response_time_ms} ms"
