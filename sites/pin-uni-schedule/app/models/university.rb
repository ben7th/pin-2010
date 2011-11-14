class University < ActiveRecord::Base
  has_many :courses
  has_many :departments
  has_many :locations
  has_many :teachers

  validates_presence_of :name
end
