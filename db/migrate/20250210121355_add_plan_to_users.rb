class AddPlanToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :plan, null: true, foreign_key: true
  end
end
