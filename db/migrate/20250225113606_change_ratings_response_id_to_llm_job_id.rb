class ChangeRatingsResponseIdToLlmJobId < ActiveRecord::Migration[8.0]
  def up
    # Add the new llm_job_id column
    add_reference :ratings, :llm_job, foreign_key: true, type: :uuid

    # Update the llm_job_id based on the response_id
    execute <<-SQL
      UPDATE ratings
      SET llm_job_id = (
        SELECT llm_job_id
        FROM responses
        WHERE responses.id = ratings.response_id
      )
    SQL

    # Make the llm_job_id not nullable
    change_column_null :ratings, :llm_job_id, false

    # Remove the old foreign key constraint
    remove_foreign_key :ratings, :responses

    # Remove the old index and column
    remove_index :ratings, :response_id if index_exists?(:ratings, :response_id)
    remove_column :ratings, :response_id

    # Add a unique constraint for user_id and llm_job_id
    add_index :ratings, [ :user_id, :llm_job_id ], unique: true
  end

  def down
    # Add back the response_id column
    add_reference :ratings, :response, foreign_key: true, type: :uuid

    # We can't restore the exact response_id values since they're gone
    # This migration is not fully reversible

    # Remove the unique constraint for user_id and llm_job_id
    remove_index :ratings, [ :user_id, :llm_job_id ] if index_exists?(:ratings, [ :user_id, :llm_job_id ])

    # Remove the llm_job_id column
    remove_reference :ratings, :llm_job
  end
end
