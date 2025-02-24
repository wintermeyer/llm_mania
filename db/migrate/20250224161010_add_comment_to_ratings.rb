class AddCommentToRatings < ActiveRecord::Migration[8.0]
  def change
    add_column :ratings, :comment, :text
  end
end
