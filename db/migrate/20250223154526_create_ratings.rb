class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings, id: :uuid do |t|
      t.references :response, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :score

      t.timestamps
    end
  end
end
