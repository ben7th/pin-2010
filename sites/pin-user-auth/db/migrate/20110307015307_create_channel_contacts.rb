class CreateChannelContacts < ActiveRecord::Migration
  def self.up
    create_table :channel_contacts do |t|
      t.integer :channel_id
      t.integer :contact_id
      t.timestamps
    end
  end

  def self.down
    drop_table :channel_contacts
  end
end
