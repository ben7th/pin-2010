class AddVoteScoreToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :vote_score, :integer,:default => 0
  end

  def self.down
  end
end
