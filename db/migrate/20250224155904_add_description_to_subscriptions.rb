class AddDescriptionToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :description, :string, null: false
  end
end
