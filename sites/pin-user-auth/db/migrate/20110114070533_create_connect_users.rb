class CreateConnectUsers < ActiveRecord::Migration
  def self.up
    create_table :connect_users do |t|
      t.integer :user_id
      t.string :connect_type
      t.string :connect_id
      t.integer :old_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_users
  end
end
