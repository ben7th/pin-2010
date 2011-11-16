class CourseItem < ActiveRecord::Base
  belongs_to :course
  belongs_to :teacher
  belongs_to :location
  has_many :user_course_items

  validates_presence_of :week_day
  validates_presence_of :order_num
  validates_presence_of :period
  validates_presence_of :in_week
  validates_presence_of :load
  validates_presence_of :location
  validates_presence_of :teacher
  validates_presence_of :course
  validates_presence_of :other_info

  def other_info_hash
    ActiveSupport::JSON.decode(other_info)
  end

  def selected_users
    self.user_course_items.map{|item|item.user}
  end
end
