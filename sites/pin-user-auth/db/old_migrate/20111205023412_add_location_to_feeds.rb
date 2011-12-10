class AddLocationToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :location, :string
  end

  def self.down
  end
end
