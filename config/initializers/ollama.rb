# Configure Ollama client defaults
require 'ollama-ai'

# Create a global Ollama client instance
$ollama_client = Ollama.new(
  credentials: { address: ENV.fetch('OLLAMA_HOST', 'http://localhost:11434') },
  options: {
    server_sent_events: true,
    timeout: ENV.fetch('OLLAMA_TIMEOUT', 60).to_i
  }
)

# Log Ollama configuration in development
if Rails.env.development?
  Rails.logger.info "Ollama configured with address: #{ENV.fetch('OLLAMA_HOST', 'http://localhost:11434')}"
  Rails.logger.info "Ollama timeout set to: #{ENV.fetch('OLLAMA_TIMEOUT', 60).to_i} seconds"
end
