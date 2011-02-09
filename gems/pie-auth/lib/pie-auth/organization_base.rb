class OrganizationBase < ActiveRecord::Base
  set_readonly(true)
  build_database_connection(CoreService::USER_AUTH,{:table_name=>"organizations"})

  def self.of_user(user)
    user.joined_organizations
  end

  def self.owner_of_user(user)
    user.own_organizations
  end

  def all_member_emails
    members.map{|member| member.email}
  end

  def all_member_users
    members.map{|member| EmailActor.get_user_by_email(member.email)}.compact
  end

  def owners
    o_members = self.members.find_all_by_kind(MemberBase::KIND_OWNER)
    o_members.map{|m|m.user}
  end

  # 判断成员中是否有这个email的
  def has_email?(email)
    user = EmailActor.get_user_by_email(email)
    return all_member_emails.include?(email) if user.blank?
    all_member_users.include?(user)
  end

  def is_owner?(user)
    owners.include?(user)
  end

  # 邮箱存在的时候返回这个邮箱地址
  # 没有邮箱地址的时候返回organization123@mindpin.com(123是id)
  def logic_email
    return self.email.blank? ? self.mindpin_email : self.email
  end

  def mindpin_email
    "organization#{self.id}@mindpin.com"
  end

  module UserMethods
    # 判断用户是否是团队的管理员
    def is_owner_of?(organization)
      organization.owners.include?(self)
    end

    def joined_organizations
      Organization.find(:all,
        :conditions=>"members.email = '#{self.email}' or members.email = '#{EmailActor.get_mindpin_email(self)}'",
        :joins=>" inner join members on organizations.id=members.organization_id"
      )
    end

    def own_organizations
      Organization.find(:all,
        :conditions=>"(members.email = '#{self.email}' or members.email = '#{EmailActor.get_mindpin_email(self)}') and kind = '#{Member::KIND_OWNER}'",
        :joins=>" inner join members on organizations.id=members.organization_id"
      )
    end
  end

  if RAILS_ENV == "test" && !self.table_exists?
    self.connection.create_table :organizations, :force => true do |t|
      t.string :name
      t.string :email
      t.string :kind
      t.timestamps
    end
  end

end
