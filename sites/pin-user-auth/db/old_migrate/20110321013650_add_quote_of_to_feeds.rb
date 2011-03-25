class AddQuoteOfToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :quote_of, :integer
  end

  def self.down
    remove_column(:feeds, :quote_of)
  end
end
