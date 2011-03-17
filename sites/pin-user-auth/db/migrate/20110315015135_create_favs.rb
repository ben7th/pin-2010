class CreateFavs < ActiveRecord::Migration
  def self.up
    create_table :favs do |t|
      t.integer :user_id
      t.integer :feed_id
      t.timestamps
    end
  end

  def self.down
    drop_table :favs
  end
end
