class UserCourseItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_item
  validates_uniqueness_of :user_id, :scope => :course_item_id

  # 选课人数
  def self.users_count
    find_by_sql(%`
        select count(*) from user_course_items
        group by user_course_items.user_id
      `).count
  end

  module UserMethods
    def self.included(base)
      base.has_many :user_course_items
      base.has_many :course_items,:through=>:user_course_items
    end

    def has_selected_course_item?(course_item)
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

    # 用户是否选过某课
    def has_selected_course?(course)
      items = (course.course_items & self.course_items)
      !items.blank?
    end

    # 用户选过的某老师的课程项，返回数组
    def selected_course_items_of_teacher(teacher)
      teacher.course_items & self.course_items
    end

    # 用户选过的在某个地点上的课程项，返回数组
    def selected_course_items_of_location(location)
      location.course_items & self.course_items
    end

    def can_select_course_item_list(week_day,order_num)
      university = self.profile.university
      CourseItem.find_by_sql(
        %`
        select course_items.* from course_items
        inner join courses on courses.id = course_items.course_id
        inner join universities on universities.id = courses.university_id
          and universities.id = #{university.id}
        where course_items.order_num = #{order_num}
          and course_items.week_day = #{week_day}
        `
      )
    end

    # {
    #     :1=>{:1=>[]},
    #     :2=>{},
    #     ..........
    #     :6=>{},
    #     :0=>{}
    # }
    def course_items_hash
      hash = _course_items_hash_new_blank_hash
      self.course_items.each do |course_item|
        week_day = course_item.week_day
        order_num = course_item.order_num

        hash[week_day][order_num].push course_item
      end
      hash
    end

    def _course_items_hash_new_blank_hash
      hash = {}
      [1,2,3,4,5,6,0].each do |week|
        hash[week]={}
        [1,2,3,4,5,6,7,8,9,10].each do |order|
          hash[week][order] = []
        end
      end
      hash
    end
  end
end
