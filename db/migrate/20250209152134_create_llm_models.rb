class CreateLlmModels < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_models do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :size, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    add_index :llm_models, :name, unique: true
    add_index :llm_models, :slug, unique: true
    add_index :llm_models, :is_active
  end
end
