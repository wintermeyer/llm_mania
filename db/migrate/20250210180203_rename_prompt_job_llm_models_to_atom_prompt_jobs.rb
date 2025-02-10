class RenamePromptJobLlmModelsToAtomPromptJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :atom_prompt_jobs do |t|
      t.references :prompt_job, null: false, foreign_key: true
      t.references :llm_model, null: false, foreign_key: true
      t.string :state, null: false, default: 'pending'
      t.text :response
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :atom_prompt_jobs, [ :prompt_job_id, :llm_model_id ], unique: true, name: 'index_atom_prompt_jobs_uniqueness'
    add_index :atom_prompt_jobs, :state
    add_index :atom_prompt_jobs, :started_at
    add_index :atom_prompt_jobs, :completed_at
  end
end
