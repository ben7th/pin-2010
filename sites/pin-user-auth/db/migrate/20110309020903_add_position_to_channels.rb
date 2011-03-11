class AddPositionToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels,:position,:integer
  end

  def self.down
  end
end
