class RenameContentToResponseInResponses < ActiveRecord::Migration[8.0]
  def change
    rename_column :responses, :content, :response
  end
end
