class AddResultToAtomPromptJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :atom_prompt_jobs, :result, :text
  end
end
