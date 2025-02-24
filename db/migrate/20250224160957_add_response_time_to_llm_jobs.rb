class AddResponseTimeToLlmJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :llm_jobs, :response_time_ms, :integer, null: true
  end
end
