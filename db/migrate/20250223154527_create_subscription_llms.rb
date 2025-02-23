class CreateSubscriptionLlms < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_llms, id: :uuid do |t|
      t.references :subscription, null: false, foreign_key: true, type: :uuid
      t.references :llm, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
