class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :roles, :name, unique: true
  end
end
