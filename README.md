# LLM Mania - LLM Comparison Tool

LLM Mania is a Rails application that allows users to compare different Large Language Models (LLMs) by submitting prompts and viewing the responses from multiple models.

## System Requirements

- Ruby 3.3.0
- PostgreSQL 14+
- Node.js 18+
- Yarn 1.22+

## Setup

1. Clone the repository
2. Install dependencies:
   ```
   bundle install
   yarn install
   ```
3. Set up the database:
   ```
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```
4. Start the development server:
   ```
   bin/dev
   ```

## Architecture

The application uses a queuing system to process LLM jobs in the background. Here's how it works:

1. Users create prompts and choose which LLMs they want to test (based on their subscription).
2. The system automatically creates LLM jobs for each prompt and LLM combination.
3. Jobs are processed in the background based on priority and position in the queue.
4. At any given time, only a configurable number of jobs can run in parallel (default: 2).
5. Admins can manage the queue by changing job priorities and positions.

## Queue Management

The queuing system uses ActiveJob with the GoodJob adapter, which stores jobs in the PostgreSQL database for reliability. This ensures that jobs are not lost even if the server is restarted.

### Key Components:

- **LlmJob**: Model representing a job to process a prompt with a specific LLM.
- **ProcessLlmJob**: Job class that processes a single LLM job.
- **QueueManagerJob**: Job class that manages the queue and starts new jobs when slots are available.
- **PeriodicQueueCheckJob**: Job class that periodically checks the queue for new jobs.
- **SystemConfig**: Model for storing system-wide configuration, including the maximum number of concurrent jobs.

## Testing on the Command Line

You can test the LLM comparison tool on the command line using the Rails console:

```bash
# Start the Rails console
bin/rails console

# Create a user (if needed)
user = User.create!(email: "test@example.com", password: "passwordpassword", first_name: "Test", last_name: "User", confirmed_at: Time.current)

# Use locally installed LLMs
llm1 = Llm.find_by(ollama_model: "llama3.1:latest") || Llm.create!(name: "Llama 3.1", ollama_model: "llama3.1:latest", size: 5, active: true, creator: "Meta")
llm2 = Llm.find_by(ollama_model: "mistral:7b") || Llm.create!(name: "Mistral 7B", ollama_model: "mistral:7b", size: 7, active: true, creator: "Mistral AI")

# Create a subscription
subscription = Subscription.create!(name: "Basic", description: "Basic subscription", max_llm_requests_per_day: 10, priority: 3, max_prompt_length: 1000, price_cents: 0, private_prompts_allowed: false, active: true)

# Associate LLMs with the subscription
SubscriptionLlm.create!(subscription: subscription, llm: llm1)
SubscriptionLlm.create!(subscription: subscription, llm: llm2)

# Create a subscription history for the user
SubscriptionHistory.create!(user: user, subscription: subscription, start_date: 1.day.ago, end_date: 30.days.from_now)

# Create a prompt (this will automatically create LLM jobs)
prompt = Prompt.create!(user: user, content: "Tell me a joke.", status: "waiting", hidden: false, flagged: false, private: false)

# Check the created jobs
prompt.llm_jobs.each do |job|
  puts "Job ID: #{job.id}, LLM: #{job.llm.name}, Status: #{job.status}, Priority: #{job.priority}, Position: #{job.position}"
end

# Ensure the SystemConfig for max_concurrent_jobs exists
unless SystemConfig.find_by(key: "max_concurrent_jobs")
  SystemConfig.create!(key: "max_concurrent_jobs", value: "2")
end

# Process the jobs directly instead of using QueueManagerJob
# This is more reliable in a console environment
prompt.llm_jobs.each do |job|
  if job.status == "queued"
    puts "Processing job #{job.id} for LLM #{job.llm.name}..."
    ProcessLlmJob.new.perform(job.id)
  end
end

# Check the job statuses again
prompt.reload
prompt.llm_jobs.each do |job|
  job.reload
  puts "Job ID: #{job.id}, LLM: #{job.llm.name}, Status: #{job.status}"
  puts "Response: #{job.response}" if job.status == "completed"
end

# If you want to use QueueManagerJob, make sure SystemConfig is initialized first:
# SystemConfig.set("max_concurrent_jobs", "2")
# QueueManagerJob.perform_now

# Change the maximum number of concurrent jobs
SystemConfig.max_concurrent_jobs = 3

# Move a job to a different position in the queue
job = LlmJob.queued.first
if job
  job.move_to_position(0) # Move to the front of the queue
end
```

## Admin Tasks

Administrators can perform the following tasks:

### View All Jobs

```ruby
LlmJob.all.order(created_at: :desc).limit(10).each do |job|
  puts "Job ID: #{job.id}, Prompt: #{job.prompt.content.truncate(30)}, LLM: #{job.llm.name}, Status: #{job.status}"
end
```

### Change Job Priority

```ruby
job = LlmJob.find(job_id)
job.update!(priority: 10) # Set to highest priority
```

### Change Job Position

```ruby
job = LlmJob.find(job_id)
job.move_to_position(0) # Move to the front of the queue
```

### Change Maximum Concurrent Jobs

```ruby
SystemConfig.max_concurrent_jobs = 5 # Allow 5 concurrent jobs
```

