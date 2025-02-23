class CreateSubscriptionHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_histories, id: :uuid do |t|
      t.references :subscription, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
