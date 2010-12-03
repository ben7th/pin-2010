class Activity < ActiveRecord::Base

  belongs_to :user, :foreign_key => "email"
  belongs_to :target, :polymorphic => true
  belongs_to :location, :polymorphic => true

  ADD_ORG_MEMBER = "add_org_member"
  DELETE_ORG_MEMBER = "delete_org_member"

  module UserMethods
    def self.included(base)
      base.has_many :activities,:foreign_key=>"email",:primary_key=>"email"
    end
  end

end
