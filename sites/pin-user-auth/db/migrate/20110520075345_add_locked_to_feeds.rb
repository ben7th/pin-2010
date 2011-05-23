class AddLockedToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds,:locked,:boolean
  end

  def self.down
  end
end
