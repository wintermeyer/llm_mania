class CreatePromptJobLlmModels < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_job_llm_models do |t|
      t.references :prompt_job, null: false, foreign_key: true
      t.references :llm_model, null: false, foreign_key: true

      t.timestamps
    end

    add_index :prompt_job_llm_models, [ :prompt_job_id, :llm_model_id ], unique: true, name: 'index_prompt_job_llm_models_uniqueness'
  end
end
