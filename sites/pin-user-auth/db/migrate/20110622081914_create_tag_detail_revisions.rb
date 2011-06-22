class CreateTagDetailRevisions < ActiveRecord::Migration
  def self.up
    create_table :tag_detail_revisions do |t|
      t.integer :tag_id
      t.integer :user_id
      t.text :detail
      t.string :message
      t.timestamps
    end
  end

  def self.down
    drop_table :tag_detail_revisions
  end
end
