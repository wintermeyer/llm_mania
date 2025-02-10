class CreatePromptJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_jobs do |t|
      t.text :prompt
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
