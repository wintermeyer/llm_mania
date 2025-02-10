class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.decimal :price, null: false, precision: 10, scale: 2
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    add_index :plans, :name, unique: true
    add_index :plans, :slug, unique: true
  end
end
