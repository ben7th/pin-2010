class Department < ActiveRecord::Base
  belongs_to :university
  has_many :courses

  validates_presence_of :name
  validates_presence_of :university
end
