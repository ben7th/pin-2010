class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :host_email
      t.string :contact_email
      t.string :code
      t.boolean :activated
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
