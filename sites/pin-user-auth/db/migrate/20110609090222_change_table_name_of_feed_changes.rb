class ChangeTableNameOfFeedChanges < ActiveRecord::Migration
  def self.up
    rename_table :feed_changes ,:feed_revisions
  end

  def self.down
  end
end
