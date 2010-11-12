class Comment < ActiveRecord::Base
  include Pacecar
  
  belongs_to :creator,:class_name => "User", :foreign_key => "creator_id"
  
  belongs_to :reply_user,:class_name=>"User",:foreign_key=>"reply_to"

  validates_presence_of :content
  validates_presence_of :creator
  validates_presence_of :url

end