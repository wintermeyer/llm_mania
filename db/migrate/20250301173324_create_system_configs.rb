class CreateSystemConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :system_configs, id: :uuid do |t|
      t.string :key, null: false
      t.text :value, null: false

      t.timestamps
    end
    add_index :system_configs, :key, unique: true
  end
end
