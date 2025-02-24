class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :gender, null: false, default: "other"
      t.string :lang, null: false, default: "en"
      t.boolean :active, null: false, default: true
      t.references :current_role, null: true, foreign_key: { to_table: :roles }, type: :uuid

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
