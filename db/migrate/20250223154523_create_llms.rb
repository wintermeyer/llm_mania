class CreateLlms < ActiveRecord::Migration[8.0]
  def change
    create_table :llms, id: :uuid do |t|
      t.string :name
      t.string :ollama_model
      t.integer :size
      t.boolean :active

      t.timestamps
    end
    add_index :llms, :name, unique: true
    add_index :llms, :ollama_model, unique: true
  end
end
