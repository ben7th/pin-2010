class ActivationApply < ActiveRecord::Base
  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :description

  validates_uniqueness_of :email
end
