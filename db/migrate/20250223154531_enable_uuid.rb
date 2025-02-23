class EnableUuid < ActiveRecord::Migration[8.0]
  def up
    # SQLite doesn't natively support UUIDs, so we'll use strings
    # This is just a marker migration to show we've enabled UUID-like functionality
    # The actual UUID generation will be handled by the application layer
  end

  def down
    # No need to do anything
  end
end
