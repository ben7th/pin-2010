class AddCreatorIdToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels,:creator_id,:integer
  end

  def self.down
  end
end
