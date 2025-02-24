class AddHiddenAndFlaggedToPrompts < ActiveRecord::Migration[8.0]
  def change
    add_column :prompts, :hidden, :boolean, null: false, default: false
    add_column :prompts, :flagged, :boolean, null: false, default: false
  end
end
