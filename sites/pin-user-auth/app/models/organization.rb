class Organization < ActiveRecord::Base
  has_many :members

  validates_presence_of :name
  validates_presence_of :email

  validates_format_of :email,:with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  def all_members_email
    members.map{|member| member.email }
  end

  def owners
    o_members = self.members.find_all_by_kind(Member::KIND_OWNER)
    o_members.map{|m|m.user}
  end

  def has_email?(email)
    all_members_email.include?(email)
  end
  
  module UserMethods
    def self.included(base)
      base.has_many :organizations
    end
  end

end
