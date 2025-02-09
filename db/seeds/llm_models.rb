# Clear existing models
LlmModel.destroy_all

# Create LLM models
[
  {
    name: "Tulu-3 8B",
    ollama_name: "tulu3:8b",
    size: 4900,
    is_active: true
  },
  {
    name: "DeepSeek Coder 1.5B",
    ollama_name: "deepseek-r1:1.5b",
    size: 1100,
    is_active: true
  },
  {
    name: "DeepSeek Coder 14B",
    ollama_name: "deepseek-r1:14b",
    size: 9000,
    is_active: true
  },
  {
    name: "DeepSeek Coder 8B",
    ollama_name: "deepseek-r1:8b",
    size: 4900,
    is_active: true
  },
  {
    name: "DeepSeek Coder 7B",
    ollama_name: "deepseek-r1:7b",
    size: 4700,
    is_active: true
  },
  {
    name: "Llama 3.3",
    ollama_name: "llama3.3:latest",
    size: 42000,
    is_active: true
  },
  {
    name: "LLaVA 13B",
    ollama_name: "llava:13b",
    size: 8000,
    is_active: true
  },
  {
    name: "LLaVA 7B",
    ollama_name: "llava:7b",
    size: 4700,
    is_active: true
  },
  {
    name: "Llama 3.1 8B",
    ollama_name: "llama3.1:8b",
    size: 4700,
    is_active: true
  }
].each do |model_data|
  LlmModel.create!(model_data)
end

puts "Created #{LlmModel.count} LLM models"
