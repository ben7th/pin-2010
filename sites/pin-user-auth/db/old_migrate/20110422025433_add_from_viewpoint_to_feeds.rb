class AddFromViewpointToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds,:from_viewpoint,:integer
  end

  def self.down
  end
end
