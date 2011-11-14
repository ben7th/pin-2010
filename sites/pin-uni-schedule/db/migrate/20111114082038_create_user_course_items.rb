class CreateUserCourseItems < ActiveRecord::Migration
  def self.up
    create_table :user_course_items do |t|
      t.integer :user_id
      t.integer :course_item_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_course_items
  end
end
