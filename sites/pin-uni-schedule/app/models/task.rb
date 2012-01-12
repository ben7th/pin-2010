class Task < ActiveRecord::Base
  belongs_to :user
  
  module UserMethods
    def self.included(base)
      base.has_many :all_tasks,:class_name=>"Task"
      base.has_many :will_tasks,:class_name=>"Task",:conditions=>"tasks.day is null"
    end
  end
end
