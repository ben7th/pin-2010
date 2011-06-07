class CreateFeedVotes < ActiveRecord::Migration
  def self.up
    create_table :feed_votes do |t|
      t.integer :feed_id
      t.integer :user_id
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_votes
  end
end
