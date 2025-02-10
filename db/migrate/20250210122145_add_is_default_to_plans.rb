class AddIsDefaultToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :is_default, :boolean, null: false, default: false
  end
end
