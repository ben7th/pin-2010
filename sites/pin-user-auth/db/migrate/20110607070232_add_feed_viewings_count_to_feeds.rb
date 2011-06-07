class AddFeedViewingsCountToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :feed_viewings_count, :integer,:default => 0
  end

  def self.down
  end
end
