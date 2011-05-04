class CreateCooperationUsers < ActiveRecord::Migration
  def self.up
    create_table :cooperation_users do |t|
      t.integer :mindmap_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cooperation_users
  end
end
