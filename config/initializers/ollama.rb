# Configure Ollama client defaults
require 'ollama-ai'
require 'faraday/net_http'

# Create a global Ollama client instance
$ollama_client = Ollama.new(
  credentials: { address: ENV.fetch('OLLAMA_HOST', 'http://localhost:11434') },
  options: {
    server_sent_events: true,
    timeout: ENV.fetch('OLLAMA_TIMEOUT', 60).to_i,
    connection: { adapter: :net_http }  # Use Net::HTTP instead of Typhoeus to avoid segfaults
  }
)

# Log Ollama configuration in development
if Rails.env.development?
  Rails.logger.info "Ollama configured with address: #{ENV.fetch('OLLAMA_HOST', 'http://localhost:11434')}"
  Rails.logger.info "Ollama timeout set to: #{ENV.fetch('OLLAMA_TIMEOUT', 60).to_i} seconds"
  Rails.logger.info "Ollama using adapter: Net::HTTP"
end
