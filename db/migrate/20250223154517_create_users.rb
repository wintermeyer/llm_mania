class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :name

      t.timestamps
    end
    add_index :users, :email
  end
end
