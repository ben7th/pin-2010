class AddSomeColumnsToFeedRevisions < ActiveRecord::Migration
  def self.up
    add_column :feed_revisions, :title, :text
    add_column :feed_revisions, :detail, :text
    add_column :feed_revisions, :tag_ids_json, :string
  end

  def self.down
  end
end
