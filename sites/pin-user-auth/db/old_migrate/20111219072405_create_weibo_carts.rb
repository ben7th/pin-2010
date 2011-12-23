class CreateWeiboCarts < ActiveRecord::Migration
  def self.up
    create_table :weibo_carts do |t|
      t.integer :user_id
      t.string :mid
      t.timestamps
    end

    add_index :weibo_carts, :mid
    add_index :weibo_statuses, :mid
  end

  def self.down
    drop_table :weibo_carts
  end
end
