class CreateCooperationChannels < ActiveRecord::Migration
  def self.up
    create_table :cooperation_channels do |t|
      t.integer :mindmap_id
      t.integer :channel_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cooperation_channels
  end
end
