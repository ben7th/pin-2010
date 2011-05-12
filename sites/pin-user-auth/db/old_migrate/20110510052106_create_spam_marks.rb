class CreateSpamMarks < ActiveRecord::Migration
  def self.up
    create_table :spam_marks do |t|
      t.integer :feed_id
      t.integer :user_id
      t.integer :count
      t.timestamps
    end
  end

  def self.down
    drop_table :spam_marks
  end
end
