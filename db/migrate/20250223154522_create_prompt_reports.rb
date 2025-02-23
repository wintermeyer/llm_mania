class CreatePromptReports < ActiveRecord::Migration[8.0]
  def change
    create_table :prompt_reports, id: :uuid do |t|
      t.references :prompt, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :reason

      t.timestamps
    end
  end
end
