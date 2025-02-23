class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses, id: :uuid do |t|
      t.references :llm_job, null: false, foreign_key: true, type: :uuid
      t.text :content

      t.timestamps
    end
  end
end
