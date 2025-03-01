class AddCreatorToLlms < ActiveRecord::Migration[8.0]
  def change
    add_column :llms, :creator, :string
  end
end
