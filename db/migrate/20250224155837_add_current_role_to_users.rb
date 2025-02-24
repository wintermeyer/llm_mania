class AddCurrentRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :current_role, foreign_key: { to_table: :roles }, type: :uuid, null: true
  end
end
