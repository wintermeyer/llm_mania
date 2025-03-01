# Create or update LLMs based on locally available Ollama models
puts "Seeding LLMs..."

# This maps Ollama model names to more user-friendly display names and size in billions of parameters
llms_data = [
  { name: "Gemma 2 9B", ollama_model: "gemma2:9b", size: 9, creator: "Google", active: true },
  { name: "Gemma 2 2B", ollama_model: "gemma2:2b", size: 2, creator: "Google", active: true },
  { name: "Phi-4", ollama_model: "phi4:latest", size: 3, creator: "Microsoft", active: true },
  { name: "Mistral 7B", ollama_model: "mistral:7b", size: 7, creator: "Mistral AI", active: true },
  { name: "Llama 3.2 1B", ollama_model: "llama3.2:1b", size: 1, creator: "Meta", active: true },
  { name: "Llama 3.2 2B", ollama_model: "llama3.2:latest", size: 2, creator: "Meta", active: true },
  { name: "DeepSeek R1 1.5B", ollama_model: "deepseek-r1:1.5b", size: 2, creator: "DeepSeek", active: true },
  { name: "Llama 3.1", ollama_model: "llama3.1:latest", size: 5, creator: "Meta", active: true },
  { name: "DeepSeek R1 8B", ollama_model: "deepseek-r1:8b", size: 8, creator: "DeepSeek", active: true },
  { name: "Tulu 3 8B", ollama_model: "tulu3:8b", size: 8, creator: "UW+AI2", active: true }
]

# Create or update LLMs
llms_data.each do |llm_data|
  llm = Llm.find_or_initialize_by(ollama_model: llm_data[:ollama_model])
  llm.update!(llm_data)
  puts "  #{llm.name} (#{llm.ollama_model}) - #{llm.size}B parameters by #{llm.creator}"
end

puts "LLMs seeding completed! Added/updated #{llms_data.size} models."
