class CreateViewpointSpamMarks < ActiveRecord::Migration
  def self.up
    create_table :viewpoint_spam_marks do |t|
      t.integer :viewpoint_id
      t.integer :user_id
      t.integer :count
      t.timestamps
    end
  end

  def self.down
    drop_table :viewpoint_spam_marks
  end
end
