# == Schema Information
# Schema version: 20081118030512
#
# Table name: nodes
#
#  id         :integer(4)      not null, primary key
#  mindmap_id  :integer(4)      not null
#  local_id   :integer(4)      
#  note       :text            
#  created_at :datetime        
#  updated_at :datetime        
#

class Node < ActiveRecord::Base
  belongs_to :mindmap

  named_scope :order_by, lambda {|field| {:order=>field} }
end
