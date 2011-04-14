class AddSendInviteEmailToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_invite_email, :boolean
  end

  def self.down
  end
end
