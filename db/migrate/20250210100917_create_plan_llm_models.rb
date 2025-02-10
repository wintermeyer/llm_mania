class CreatePlanLlmModels < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_llm_models do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :llm_model, null: false, foreign_key: true

      t.timestamps
    end

    add_index :plan_llm_models, [ :plan_id, :llm_model_id ], unique: true
  end
end
