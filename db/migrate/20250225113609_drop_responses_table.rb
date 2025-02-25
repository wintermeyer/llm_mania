class DropResponsesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :responses
  end

  def down
    create_table :responses, id: :uuid do |t|
      t.references :llm_job, null: false, foreign_key: true, type: :uuid
      t.text :response

      t.timestamps
    end
  end
end
