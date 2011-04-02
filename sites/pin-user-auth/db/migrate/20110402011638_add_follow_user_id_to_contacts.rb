class AddFollowUserIdToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts,:follow_user_id,:integer
  end

  def self.down
  end
end
