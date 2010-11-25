# == Schema Information
# Schema version: 20081118030512
#
# Table name: visit_counters
#
#  id            :integer(4)      not null, primary key
#  resource_id   :integer(4)      not null
#  resource_type :string(255)     default(""), not null
#  visit_count   :integer(4)      default(0)
#  created_at    :datetime        
#  updated_at    :datetime        
#

class VisitCounter < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  
  # 计数值增加
  # 暂时先直接持久化
  # 引入memcache以后，不直接持久化
  def rise
    self.visit_count+=1
    self.save
  end
  
end
