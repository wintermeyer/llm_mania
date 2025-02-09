class AddOllamaNameToLlmModels < ActiveRecord::Migration[8.0]
  def up
    # First add the column as nullable
    add_column :llm_models, :ollama_name, :string

    # Update existing records with a default value based on their name
    LlmModel.find_each do |model|
      default_ollama_name = model.name.downcase.gsub(/[^a-z0-9]/, '').gsub(/\s+/, '') + ":latest"
      model.update_column(:ollama_name, default_ollama_name)
    end

    # Now make it non-nullable
    change_column_null :llm_models, :ollama_name, false
    add_index :llm_models, :ollama_name, unique: true
  end

  def down
    remove_column :llm_models, :ollama_name
  end
end
