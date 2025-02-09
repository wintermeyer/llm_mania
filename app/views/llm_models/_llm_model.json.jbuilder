json.extract! llm_model, :id, :name, :slug, :size, :is_active, :created_at, :updated_at
json.url llm_model_url(llm_model, format: :json)
