class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :name
      t.decimal :price
      t.integer :daily_prompt_limit

      t.timestamps
    end
    add_index :subscriptions, :name, unique: true
  end
end
