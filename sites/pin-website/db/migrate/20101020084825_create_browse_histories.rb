class CreateBrowseHistories < ActiveRecord::Migration
  def self.up
    create_table :browse_histories do |t|
      t.integer :user_id
      t.string :url
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :browse_histories
  end
end
