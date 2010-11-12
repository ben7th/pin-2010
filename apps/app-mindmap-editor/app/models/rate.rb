# == Schema Information
# Schema version: 20081118030512
#
# Table name: rates
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)      
#  rateable_id   :integer(4)      
#  rateable_type :string(30)      
#  rate          :integer(4)      
#  created_at    :datetime        
#  updated_at    :datetime        
#

class Rate < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true
  belongs_to :user
  
  attr_accessible :rate
end
