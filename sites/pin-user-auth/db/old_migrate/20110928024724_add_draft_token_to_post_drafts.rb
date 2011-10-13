class AddDraftTokenToPostDrafts < ActiveRecord::Migration
  def self.up
    add_column :post_drafts,:draft_token,:string
  end

  def self.down
  end
end
