class CreateSendScopes < ActiveRecord::Migration
  def self.up
    create_table :send_scopes do |t|
      t.string :param
      t.integer :feed_id
      t.integer :scope_id
      t.string :scope_type
      t.timestamps
    end
  end

  def self.down
    drop_table :send_scopes
  end
end
