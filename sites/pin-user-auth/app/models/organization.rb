class Organization < ActiveRecord::Base
  has_many :members,:dependent=>:destroy

  validates_presence_of :name
  validates_presence_of :email

  named_scope :of_user, lambda{ |user|
    {:joins=>" inner join members on organizations.id=members.organization_id",
      :conditions=>"members.email = '#{user.email}'"}
  }

  named_scope :common_of_user, lambda{ |user|
    {:joins=>" inner join members on organizations.id=members.organization_id",
      :conditions=>"members.email = '#{user.email}' and kind = '#{Member::KIND_COMMON}'"}
  }

  named_scope :owner_of_user, lambda{ |user|
    {:joins=>" inner join members on organizations.id=members.organization_id",
      :conditions=>"members.email = '#{user.email}' and kind = '#{Member::KIND_OWNER}'"}
  }

  #SELECT `organizations`.* FROM `organizations` INNER JOIN `members` ON `organizations`.id = `members`.organization_id WHERE ((`members`.email = 271)

  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  def all_members_email
    members.map{|member| member.email }
  end

  def owners
    o_members = self.members.find_all_by_kind(Member::KIND_OWNER)
    o_members.map{|m|m.user}
  end

  def can_leave?(user)
    !(owners.count == 1 && is_owner?(user))
  end

  def is_owner?(user)
    owners.include?(user)
  end

  def leave(user)
    if can_leave?(user)
      member = Member.find_by_organization_id_and_email(id,user.email)
      return member.destroy if member
    end
    return false
  end

  def has_email?(email)
    all_members_email.include?(email)
  end

  module UserMethods
    def is_owner_of?(organization)
      organization.owners.include?(self)
    end
  end
  
end