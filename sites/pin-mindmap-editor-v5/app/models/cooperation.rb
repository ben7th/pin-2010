class Cooperation < ActiveRecord::Base

  EDITOR = "editor"
  VIEWER = "viewer"

  belongs_to :mindmap

  validates_presence_of :email
  validates_inclusion_of :kind, :in => [EDITOR,VIEWER]
  validates_presence_of :mindmap

  # 邮箱所有者
  def email_actor
    EmailActor.new(self.email)
  end

  # Cooperation 的 email 可能是 注册用户邮箱，未注册用户邮箱，团队邮箱
  # 当 email 对应为 团队邮箱时，该方法返回一个团队成员邮箱组成的 邮箱数组
  # 当 email 对应为 注册用户邮箱，未注册用户邮箱，该方法返回 长度为一的 邮箱数组
  def emails
    # 如果 是团队
    org = Organization.parse_by_email(self.email)
    return org.all_member_emails if org
    return [self.email]
  end

  # Cooperation 的 email 可能是 注册用户邮箱，未注册用户邮箱，团队邮箱
  # 当 email 对应为 注册用户邮箱，团队邮箱时，该方法返回一组用户
  # 当 email 对应为 未注册用户邮箱，该方法返回空数组
  def users
    # 如果是 用户
    user = User.find_by_email(self.email)
    return [user] if user
    # 如果 是团队
    org = Organization.parse_by_email(self.email)
    return org.all_member_users if org
    return []
  end

  module MindmapMethods
    def self.included(base)
      # 与他人共同协同的导图(包括自己创建的和别人协同给自己的)
      base.named_scope :cooperate_of_user, lambda {|user,kind|
        org_emails = user.organizations.map{|org|org.cooperation_email}
        emails = [org_emails,user.email].flatten
        emails_str = emails.map{|email|"'#{email}'"}*","
        {:joins=>" inner join cooperations on mindmaps.id = cooperations.mindmap_id",
          :conditions=>"(mindmaps.user_id = #{user.id} or cooperations.email in (#{emails_str}) ) and cooperations.kind = '#{kind}'"}
      }
      base.extend(ClassMethods)
      base.has_many :cooperations
    end

    module ClassMethods
      # 与他人共同编辑的导图(包括自己创建的和别人协同给自己的)
      def cooperate_edit_of_user(user)
        self.cooperate_of_user(user,Cooperation::EDITOR).uniq
      end

      # 与他人共同查看的导图(包括自己创建的和别人协同给自己的)
      def cooperate_view_of_user(user)
        self.cooperate_of_user(user,Cooperation::VIEWER).uniq
      end
    end

    def cooperate_edit_email_list
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{EDITOR}'")
      coos.map{|coo|coo.email}.flatten.uniq
    end

    def cooperate_view_email_list
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{VIEWER}'")
      coos.map{|coo|coo.email}.flatten.uniq
    end

    # 协同编辑 邮箱所有者数组
    def cooperate_edit_email_actors
      coos = self.cooperations.find(:all,:conditions=>"cooperations.kind = '#{EDITOR}'")
      coo_targets = coos.map{|coo|coo.email_actor}
      EmailActor.unique [EmailActor.new(self.user.email),coo_targets].flatten.compact
    end

    # 协同查看 邮箱所有者数组
    def cooperate_view_email_actors
      coos = self.cooperations.find(:all,:conditions=>"cooperations.kind = '#{VIEWER}'")
      coo_targets = coos.map{|coo|coo.email_actor}
      EmailActor.unique [EmailActor.new(self.user.email),coo_targets].flatten.compact
    end
    
    # 增加协同编辑成员
    def add_cooperate_editor(user_or_email)
      email = (user_or_email.class == User) ? user_or_email.email : user_or_email
      return if !!Cooperation.find_by_email_and_mindmap_id(email,self.id)
      Cooperation.create(:email=>email,:mindmap=>self,:kind=>EDITOR)
    end
    
    # 删除协同编辑成员
    def remove_cooperate_editor(user_or_email)
      email = (user_or_email.class == User) ? user_or_email.email : user_or_email
      coos = Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,EDITOR)
      coos.each{|coo|coo.destroy}
    end

    # 增加协同查看成员
    def add_cooperate_viewer(user_or_email)
      email = (user_or_email.class == User) ? user_or_email.email : user_or_email
      return if !!Cooperation.find_by_email_and_mindmap_id(email,self.id)
      Cooperation.create(:email=>email,:mindmap=>self,:kind=>VIEWER)
    end

    # 删除协同查看成员
    def remove_cooperate_viewer(user_or_email)
      email = (user_or_email.class == User) ? user_or_email.email : user_or_email
      coos = Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,VIEWER)
      coos.each{|coo|coo.destroy}
    end

    # 删除所有协同编辑成员
    def remove_all_cooperate_editor
      coos = Cooperation.find_all_by_mindmap_id_and_kind(self.id,EDITOR)
      coos.each{|coo|coo.destroy}
    end

    # 删除所有协同查看成员
    def remove_all_cooperate_viewer
      coos = Cooperation.find_all_by_mindmap_id_and_kind(self.id,VIEWER)
      coos.each{|coo|coo.destroy}
    end

    # user 对 这个导图 有协同编辑的权限
    def cooperate_edit?(user)
      return false if !user
      return true if self.user == user

      org_emails = user.organizations.map{|org|org.cooperation_email}
      emails = [org_emails,user.email].flatten.uniq
      coos = emails.map{|email|Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,EDITOR)}.flatten
      coos.count != 0
    end

    # user 对 这个导图 有协同查看的权限
    def cooperate_view?(user)
      return false if !user
      return true if self.user == user

      org_emails = user.organizations.map{|org|org.cooperation_email}
      emails = [org_emails,user.email].flatten
      coos = emails.map{|email|Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,VIEWER)}.flatten
      coos.count != 0
    end

  end

  module UserMethods
    # 根据用户属于的团队邮箱和用户自己的邮箱
    # 找到对应的 edit cooperations 记录
    def edit_cooperations
      org_emails = self.organizations.map{|org|org.cooperation_email}
      emails = [org_emails,self.email].flatten
      emails.map{|email|Cooperation.find_all_by_email_and_kind(email,EDITOR)}.flatten
    end

    # 根据用户属于的团队邮箱和用户自己的邮箱
    # 找到对应的 view cooperations 记录
    def view_cooperations
      org_emails = self.organizations.map{|org|org.cooperation_email}
      emails = [org_emails,self.email].flatten
      emails.map{|email|Cooperation.find_all_by_email_and_kind(email,VIEWER)}.flatten
    end

    # 被别人协同编辑的导图
    def cooperate_edit_mindmaps
      coos = self.edit_cooperations
      mindmaps = coos.map{|coo|coo.mindmap}
      mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id}
    end

    # 被别人协同查看的导图
    def cooperate_view_mindmaps
      coos = self.view_cooperations
      mindmaps = coos.map{|coo|coo.mindmap}
      mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id}
      mindmaps.select{|mindmap|mindmap.private}
    end
  end

end
