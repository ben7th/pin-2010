class Cooperation < ActiveRecord::Base
  EDITOR = "editor"
  VIEWER = "viewer"
  belongs_to :mindmap
end

class Organization < UserAuthAbstract
end

def get_organization_by_email(email)
  ma = /organization(\d+)@mindpin.com/.match(email)
  Organization.find_by_email(email) || Organization.find_by_id(ma[1])
rescue
  nil
end

def get_user_by_email(email)
  ma = /user(\d+)@mindpin.com/.match(email)
  User.find_by_email(email) || User.find_by_id(ma[1])
rescue
  nil
end

def get_obj_by_email(email)
  get_user_by_email(email) || get_organization_by_email(email)
end

Cooperation.transaction do
  coos = Cooperation.all
  coos_count = coos.length
  coos.each_with_index do |coo,index|
    p "正在转换#{index+1}/#{coos_count}"
    next if coo.kind != Cooperation::EDITOR
    obj = get_obj_by_email(coo.email)
    mindmap = coo.mindmap
    next if obj.blank? || mindmap.blank?
    case obj
    when User
      CooperationUser.create!(:user=>obj,:mindmap=>mindmap)
    when Organization
      next if obj.channel_id.blank?
      channel = Channel.find(obj.channel_id)
      CooperationChannel.create!(:channel=>channel,:mindmap=>mindmap)
    end
  end
end