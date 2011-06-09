class CreateTagShares < ActiveRecord::Migration
  def self.up
    create_table :tag_shares do |t|
      t.integer :tag_id
      t.integer :creator_id
      t.string :url
      t.string :title
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_shares
  end
end
