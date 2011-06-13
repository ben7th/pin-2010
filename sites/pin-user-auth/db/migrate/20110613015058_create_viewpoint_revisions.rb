class CreateViewpointRevisions < ActiveRecord::Migration
  def self.up
    create_table :viewpoint_revisions do |t|
      t.integer :viewpoint_id
      t.text :content
      t.string :message
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :viewpoint_revisions
  end
end
