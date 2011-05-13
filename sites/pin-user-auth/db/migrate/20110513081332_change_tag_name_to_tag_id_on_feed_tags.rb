class ChangeTagNameToTagIdOnFeedTags < ActiveRecord::Migration
  def self.up
    add_column    :feed_tags, :tag_id,   :integer
    remove_column :feed_tags, :tag_name
  end

  def self.down
  end
end
