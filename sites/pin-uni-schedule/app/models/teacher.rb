class Teacher < ActiveRecord::Base
  belongs_to :university
  has_many :course_items

  validates_presence_of :name
  validates_presence_of :tid
  validates_presence_of :university
end
