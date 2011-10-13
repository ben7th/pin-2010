class ChangeColumnsOnPostDrafts < ActiveRecord::Migration
  def self.up
    add_column :post_drafts,:title,:string
    add_column :post_drafts,:photo_names,:string
    add_column :post_drafts,:collection_ids,:string
    rename_column :post_drafts,:content,:detail
    add_column :post_drafts,:text_format,:string,:null=>false,:default=>"markdown"
  end

  def self.down
  end
end
