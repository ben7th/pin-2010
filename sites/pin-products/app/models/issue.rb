class Issue < ActiveRecord::Base
  class Status
    ALIVE = "alive"
    DONE = "done"
  end
  STATUSES = [
  Issue::Status::ALIVE,
  Issue::Status::DONE
  ]
  validates_presence_of :product
  validates_presence_of :content
  validates_inclusion_of :status, :in =>STATUSES 
  belongs_to :product
  has_many :comments,:class_name=>"IssueComment",:order=>"id desc"
  
  before_validation(:on => :create) do
    self.status = Status::ALIVE 
  end
  
  def done?
    self.status == Issue::Status::DONE
  end
  
  def done
    self.update_attribute(:status,Issue::Status::DONE)
  end
end
