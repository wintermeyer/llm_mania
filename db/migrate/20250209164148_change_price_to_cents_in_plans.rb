class ChangePriceToCentsInPlans < ActiveRecord::Migration[8.0]
  def up
    add_column :plans, :price_cents, :integer, null: false, default: 0

    # Convert existing prices to cents
    Plan.find_each do |plan|
      plan.update_column(:price_cents, (plan.price * 100).to_i)
    end

    remove_column :plans, :price
  end

  def down
    add_column :plans, :price, :decimal, precision: 10, scale: 2, null: false, default: 0

    # Convert cents back to decimal
    Plan.find_each do |plan|
      plan.update_column(:price, plan.price_cents.to_f / 100)
    end

    remove_column :plans, :price_cents
  end
end
