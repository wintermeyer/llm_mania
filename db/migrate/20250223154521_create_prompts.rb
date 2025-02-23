class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.text :content
      t.boolean :private
      t.string :status

      t.timestamps
    end
    add_index :prompts, :status
  end
end
