class CreateFeedChannels < ActiveRecord::Migration
  def self.up
    create_table :feed_channels do |t|
      t.integer :feed_id
      t.integer :channel_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_channels
  end
end
