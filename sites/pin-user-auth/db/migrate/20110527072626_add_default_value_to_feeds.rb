class AddDefaultValueToFeeds < ActiveRecord::Migration
  def self.up
    change_column(:feeds, :locked, :boolean,:null =>false, :default =>false)
    change_column(:feeds, :hidden, :boolean,:null =>false, :default =>false)
  end

  def self.down
  end
end
