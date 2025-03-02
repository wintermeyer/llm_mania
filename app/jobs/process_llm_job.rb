class ProcessLlmJob < ApplicationJob
  queue_as :llm_jobs

  # Retry with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Discard if the job no longer exists
  discard_on ActiveRecord::RecordNotFound

  def perform(llm_job_id)
    llm_job = LlmJob.find(llm_job_id)

    # Skip if the job is not in queued status
    return unless llm_job.status == "queued"

    # Mark as processing
    llm_job.start_processing!

    # Update the prompt status
    llm_job.prompt.update_status

    begin
      # Here we would integrate with the actual LLM API
      # For now, we'll simulate processing
      start_time = Time.current

      # Call LLM API using Ollama
      response = call_llm_api(llm_job)

      # Calculate response time
      end_time = Time.current
      response_time_ms = ((end_time - start_time) * 1000).to_i

      # Mark as completed
      llm_job.complete!(response, response_time_ms)
    rescue => e
      # Mark as failed
      llm_job.fail!(e.message)

      # Re-raise the error for retry mechanism
      raise
    ensure
      # Update the prompt status
      llm_job.prompt.update_status

      # Process the next job in the queue
      QueueManagerJob.perform_later
    end
  end

  private

  def call_llm_api(llm_job)
    # Get the model name from the LLM record
    model = llm_job.llm.ollama_model

    # Get the prompt content
    prompt = llm_job.prompt.content

    # Call the Ollama API
    begin
      # Log the request in development
      if Rails.env.development?
        Rails.logger.info "Calling Ollama API with model: #{model}"
        Rails.logger.info "Prompt: #{prompt.truncate(100)}"
      end

      # Generate a response using the specified model and the global Ollama client
      result = $ollama_client.generate(
        { model: model, prompt: prompt }
      )

      # The result is an array of events when streaming is enabled
      # The last event contains the complete response
      if result.is_a?(Array) && result.last['done'] == true
        # Extract the full response from all events
        full_response = result.map { |event| event['response'] }.join('')
        full_response
      else
        # For non-streaming responses
        result.fetch('response', "No response received from #{model}")
      end
    rescue => e
      Rails.logger.error("Ollama API error: #{e.message}")

      # If we're in development mode and there's an error, provide a helpful message
      if Rails.env.development?
        "Error calling Ollama API for model '#{model}': #{e.message}. " \
               "Make sure Ollama is running locally with 'ollama serve' and the model is installed with 'ollama pull #{model}'."
      else
        # In production, re-raise the error
        raise
      end
    end
  end
end
