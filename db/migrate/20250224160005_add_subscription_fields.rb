class AddSubscriptionFields < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :max_llm_requests_per_day, :integer, null: false
    add_column :subscriptions, :priority, :integer, null: false
    add_column :subscriptions, :max_prompt_length, :integer, null: false
    add_column :subscriptions, :price_cents, :integer, null: false
    add_column :subscriptions, :private_prompts_allowed, :boolean, null: false, default: false
    add_column :subscriptions, :active, :boolean, null: false, default: true
  end
end
