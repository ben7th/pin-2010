class RenameTodoItemsToFeedDetails < ActiveRecord::Migration
  def self.up
    rename_table :todo_items, :feed_details
  end

  def self.down
  end
end
