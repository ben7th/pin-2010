class Course < ActiveRecord::Base
  belongs_to :university
  belongs_to :department
  has_many :course_items

  validates_presence_of :name
  validates_presence_of :cid
  validates_presence_of :university
  validates_presence_of :department
end
