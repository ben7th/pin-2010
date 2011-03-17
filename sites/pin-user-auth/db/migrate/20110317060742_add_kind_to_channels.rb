class AddKindToChannels < ActiveRecord::Migration
  def self.up
    add_column :channels, :kind, :string
  end

  def self.down
  end
end
