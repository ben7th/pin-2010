class Course < ActiveRecord::Base
  belongs_to :university
  belongs_to :department
  has_many :course_items

  validates_presence_of :name
  validates_presence_of :cid
  validates_presence_of :university
  validates_presence_of :department

  #收录课程数 course_items_count
  #选课节数   user_course_items_count
  #选课人数   users_count (只算选过课的用户)
  #教师人数   teachers_count
  #上课地点数 locations_count
  def self.system_meta_info
    {
      :course_items_count=>CourseItem.count,
      :user_course_items_count=>UserCourseItem.count,
      :users_count=>UserCourseItem.users_count,
      :teachers_count=>Teacher.count,
      :locations_count=>Location.count
    }
  end

end
