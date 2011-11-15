class UserCourseItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_item
  validates_uniqueness_of :user_id, :scope => :course_item_id

  module UserMethods
    def course_item_is_select?(course_item)
      items = UserCourseItem.find(:all,
        :conditions=>{:course_item_id=>course_item.id,:user_id=>self.id})
      !items.blank?
    end

    def select_course_item(course_item)
      UserCourseItem.create(:course_item=>course_item,:user=>self)
    end

    def cancel_select_course_item(course_item)
      items = UserCourseItem.find(:all,
        :conditions=>{:course_item_id=>course_item.id,:user_id=>self.id})
      items.each{|item|item.destroy}
    end

    def select_course_items(order_num,week_day)
      CourseItem.find(:all,
        :conditions=>{:order_num=>order_num,:week_day=>week_day},
        :joins=>"inner join user_course_items on user_course_items.course_item_id = course_items.id and user_course_items.user_id = #{self.id}"
      )
    end
  end
end
