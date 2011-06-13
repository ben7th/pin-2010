class AddMessageToFeedRevisions < ActiveRecord::Migration
  def self.up
    add_column :feed_revisions, :message, :string, :null =>false, :default =>""
  end

  def self.down
  end
end
