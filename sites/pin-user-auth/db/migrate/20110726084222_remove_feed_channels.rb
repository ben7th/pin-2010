class RemoveFeedChannels < ActiveRecord::Migration
  def self.up
    drop_table :feed_channels
  end

  def self.down
  end
end
