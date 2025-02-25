class AddResponseToLlmJobs < ActiveRecord::Migration[8.0]
  def up
    add_column :llm_jobs, :response, :text

    # Migrate data from responses to llm_jobs
    execute <<-SQL
      UPDATE llm_jobs
      SET response = (
        SELECT response
        FROM responses
        WHERE responses.llm_job_id = llm_jobs.id
        LIMIT 1
      )
      WHERE EXISTS (
        SELECT 1
        FROM responses
        WHERE responses.llm_job_id = llm_jobs.id
      )
    SQL
  end

  def down
    remove_column :llm_jobs, :response
  end
end
