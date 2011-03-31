class AddOauthTokenAndOauthTokenSecretToConnectUsers < ActiveRecord::Migration
  def self.up
    add_column :connect_users,:oauth_token,:string
    add_column :connect_users,:oauth_token_secret,:string
  end

  def self.down
  end
end
