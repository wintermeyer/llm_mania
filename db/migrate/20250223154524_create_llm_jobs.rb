class CreateLlmJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_jobs, id: :uuid do |t|
      t.references :prompt, null: false, foreign_key: true, type: :uuid
      t.references :llm, null: false, foreign_key: true, type: :uuid
      t.integer :priority
      t.integer :position
      t.string :status

      t.timestamps
    end
    add_index :llm_jobs, :position
    add_index :llm_jobs, :status
  end
end
