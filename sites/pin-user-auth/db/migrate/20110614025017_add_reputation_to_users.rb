class AddReputationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reputation, :integer, :default => 0, :null=>false
  end

  def self.down
  end
end
