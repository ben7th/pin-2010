class CreateUserViewPosts < ActiveRecord::Migration
  def self.up
    create_table :user_view_posts do |t|
      t.integer :user_id
      t.integer :post_id
      t.string :attitude
      t.timestamps
    end
  end

  def self.down
    drop_table :user_view_posts
  end
end
