class ChangeLocalIdToNodes < ActiveRecord::Migration
  def self.up
    change_column :nodes,:local_id,:string
  end

  def self.down
  end
end
