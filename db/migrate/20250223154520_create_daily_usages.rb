class CreateDailyUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_usages, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.date :date
      t.integer :prompt_count

      t.timestamps
    end
  end
end
