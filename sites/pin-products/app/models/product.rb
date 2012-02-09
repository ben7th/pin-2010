class Product < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :code
  validates_presence_of :description
  
  has_many :issues,:order=>"id desc"
end
