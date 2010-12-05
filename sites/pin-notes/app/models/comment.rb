class Comment < ActiveRecord::Base
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"
  validates_presence_of :email
  validates_presence_of :content
  validates_presence_of :note_id

end