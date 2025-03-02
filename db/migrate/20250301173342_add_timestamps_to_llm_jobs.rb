class AddTimestampsToLlmJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :llm_jobs, :started_at, :datetime
    add_column :llm_jobs, :completed_at, :datetime
    add_column :llm_jobs, :error_message, :text
  end
end
