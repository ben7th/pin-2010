class AddHiddenToFeeds < ActiveRecord::Migration
  def self.up
    add_column(:feeds, :hidden, :boolean)
  end

  def self.down
    remove_column(:feeds, :hidden)
  end
end
