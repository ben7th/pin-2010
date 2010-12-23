class Activity < ActiveRecord::Base

  belongs_to :user, :foreign_key => "email"

  ADD_ORG_MEMBER = "add_org_member"

  def self.create_add_org_member(user,organization,member)
    Activity.create(:operator=>user.email,
      :location=>"Organization##{organization.id}",
      :detail=>{:email=>member.email}.to_json,
      :event=>Activity::ADD_ORG_MEMBER)
  end

  def at
    location_split = self.location.split("#")
    Object.const_get(location_split[0]).find_by_id(location_split[1])
  end

  def detail_hash
    JSON.parse(self.detail)
  end

  module UserMethods
    def self.included(base)
      base.has_many :activities,:foreign_key=>"email",:primary_key=>"email"
    end
  end

end
