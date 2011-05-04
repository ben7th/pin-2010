class CreateViewpointVotes < ActiveRecord::Migration
  def self.up
    create_table :viewpoint_votes do |t|
      t.integer :user_id
      t.integer :viewpoint_id
      t.string :status # UP | DOWN
      t.timestamps
    end
  end

  def self.down
    drop_table :viewpoint_votes
  end
end
