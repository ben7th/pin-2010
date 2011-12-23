class CreateWeiboStatuses < ActiveRecord::Migration
  def self.up
    create_table :weibo_statuses do |t|
      t.string :mid
      t.string :uname
      t.integer :uid
      t.text :json
      t.timestamps
    end
  end

  def self.down
    drop_table :weibo_statuses
  end
end
