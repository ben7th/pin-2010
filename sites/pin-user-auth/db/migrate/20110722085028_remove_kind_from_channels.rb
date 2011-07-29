class RemoveKindFromChannels < ActiveRecord::Migration
  def self.up
    remove_column(:channels, :kind)
  end

  def self.down
  end
end
