class CreateCourseItems < ActiveRecord::Migration
  def self.up
    create_table :course_items do |t|
      t.integer :week_day
      t.integer :order_num
      t.integer :period
      t.string :in_week
      t.integer :load
      t.integer :location_id
      t.integer :teacher_id
      t.integer :course_id
      t.text :other_info
      t.timestamps
    end
  end

  def self.down
    drop_table :course_items
  end
end
