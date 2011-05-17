class Organization < UserAuthAbstract
  has_many :members,:foreign_key => "organization_id",:dependent=>:destroy
  def all_member_users
    members.map{|member| EmailActor.get_user_by_email(member.email)}.compact
  end

  def owners
    o_members = self.members.find_all_by_kind(Member::KIND_OWNER)
    o_members.map{|m|EmailActor.get_user_by_email(m.email)}.compact
  end

  def mindpin_email
    "organization#{self.id}@mindpin.com"
  end
end

class Member < UserAuthAbstract
  KIND_COMMON = 'common'
  KIND_OWNER = 'owner'
  belongs_to :organization
end

Channel.transaction do
  orgs = Organization.all
  orgs_count = orgs.length
  orgs.each_with_index do |org,index|
    p "正在转换#{index+1}/#{orgs_count}"
    org_creator = org.owners.first
    org_name = org.name
    org_members = org.all_member_users
    next if org_creator.blank? || org_name.blank?
    channel = Channel.create!(:name=>org_name,:creator=>org_creator)
    # 增加成员到频道
    org_members.each do |user|
      p "channel_#{channel.id} add user_#{user.id}"
      channel.add_user(user)
    end
    org.update_attributes!(:channel_id=>channel.id)
  end
end

