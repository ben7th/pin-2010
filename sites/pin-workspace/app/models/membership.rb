class Membership < ActiveRecord::Base
  belongs_to :workspace

  JOINED  = "JOINED"    # 正式成员
  APPLY   = "APPLY"     # 申请加入
  REFUSED = "REFUSED"   # 申请加入被拒绝
  QUIT    = "QUIT"      # 退出
  INVITE  = "INVITE"    # 邀请
  BANED  = "BANED"    # 禁止了，加入了黑名单

  def validate_on_create
    ms = Membership.find(:first,:conditions=>{:email=>self.email,:workspace_id=>self.workspace_id})
    if !ms.blank?
      errors.add_to_base("不能重复创建")
    end
  end
  
  require 'uuidtools'
  before_create :set_uuid_code
  def set_uuid_code
    self.uuid_code = UUIDTools::UUID.random_create.to_s
  end

  # 已经退出的 返回false 
  def quit
    return false if self.status == Membership::QUIT
    self.update_attributes!(:status=>Membership::QUIT)
  end

  # 已经加入的 返回false
  def join
    return "已经加入" if self.status == Membership::JOINED
    return "无法申请" if self.status == Membership::BANED
    return "加入成功" if self.update_attributes!(:status=>Membership::JOINED)
  end

  # 同意某人的申请
  def approve
    self.update_attributes!(:status=>Membership::JOINED)
  end

  # 拒绝某人的申请
  def refuse
    self.update_attributes!(:status=>Membership::REFUSED)
  end

  # 将某人拉入黑名单
  def ban
    self.update_attributes!(:status=>Membership::BANED)
  end

  # 把某人从黑名单中解救出来
  def unban
    self.update_attributes!(:status=>Membership::JOINED)
  end

  module UserMethods
    # user 申请 加入 workspace
    # 第一次申请
    # 重复申请
    # 被拒绝后，再次申请
    def apply_join(workspace)
      ms = Membership.find(:first,:conditions=>{:email=>self.email,:workspace_id=>workspace.id})
      case true
      when ms.blank?
        !!Membership.create(:email=>self.email,:workspace=>workspace,:status=>Membership::APPLY)
      when ms.status != Membership::JOINED && ms.status != Membership::BANED
        ms.update_attributes(:status=>Membership::APPLY)
      else
        return false
      end
    end

  end

  module WorkspaceMethods
    def self.included(base)
      base.has_many :memberships
      base.has_many :apply_memberships,:conditions=>["memberships.status = ?",Membership::APPLY],:class_name=>"Membership"
      base.has_many :joined_memberships,:conditions=>["memberships.status = ?",Membership::JOINED],:class_name=>"Membership"
      base.has_many :baned_memberships,:conditions=>["memberships.status = ?",Membership::BANED],:class_name=>"Membership"
    end

    def apply_member_emails
      self.apply_memberships.map{|ms| ms.email}
    end

    def member_emails
      self.joined_memberships.map{|ms| ms.email}
    end

    def baned_member_emails
      self.baned_memberships.map{|ms| ms.email}
    end

    # 增加成员：直接增加，同意申请
    def add_member(user_or_email)
      email = _to_email(user_or_email)
      ms = Membership.find(:first,:conditions=>{:email=>email,:workspace_id=>self.id})
      return Membership.create(:email=>email,:workspace=>self,:status=>Membership::JOINED) if ms.blank?
      ms.update_attributes(:status=>Membership::JOINED) if ms.status != Membership::JOINED
      return ms
    end

    # 增加多个联系人
    def add_members(emails)
      emails.each{|email|add_member(email)}
    end

    # 邀请多个人
    def invite_members(emails)
      emails.each{|email|invite_member(email)}
    end

    def invite_member(user_or_email)
      email = _to_email(user_or_email)
      ms = Membership.find(:first,:conditions=>{:email=>email,:workspace_id=>self.id})
      return Membership.create(:email=>email,:workspace=>self,:status=>Membership::INVITE) if ms.blank?
      ms.update_attributes(:status=>Membership::INVITE) if ms.status != Membership::JOINED
      return ms
    end

    # 拒绝某用户加入
    def refuse_join(user_or_email)
      email = _to_email(user_or_email)
      ms = Membership.find(:first,:conditions=>{:email=>email,:workspace_id=>self.id})
      return ms.update_attributes(:status=>Membership::REFUSED)
    end

    # arg 可能是 user ，也可能是 email
    def _to_email(arg)
      case arg
      when User then arg.email
      when String then arg
      end
    end

  end
end
