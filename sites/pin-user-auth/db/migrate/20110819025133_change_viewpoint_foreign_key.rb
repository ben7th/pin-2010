class ChangeViewpointForeignKey < ActiveRecord::Migration
  def self.up
    rename_column(:viewpoint_comments,:viewpoint_id,:post_id)
    rename_column(:viewpoint_revisions,:viewpoint_id,:post_id)
    rename_column(:viewpoint_spam_marks,:viewpoint_id,:post_id)
    rename_column(:viewpoint_votes,:viewpoint_id,:post_id)

    rename_table(:viewpoint_comments,:post_comments)
    rename_table(:viewpoint_drafts,:post_drafts)
    rename_table(:viewpoint_revisions,:post_revisions)
    rename_table(:viewpoint_spam_marks,:post_spam_marks)
    rename_table(:viewpoint_votes,:post_votes)
  end

  def self.down
  end
end
