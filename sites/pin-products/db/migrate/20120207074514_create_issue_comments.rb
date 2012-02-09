class CreateIssueComments < ActiveRecord::Migration
  def change
    create_table :issue_comments do |t|
      t.integer :issue_id
      t.integer :user_id
      t.text :content
      t.integer :reply_comment_id
      t.integer :reply_comment_user_id
      t.timestamps
    end
  end
end
