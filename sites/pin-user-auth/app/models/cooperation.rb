class Cooperation < ActiveRecord::Base

  build_database_connection(CoreService::MINDMAP_EDITOR)

  EDITOR = "editor"
  VIEWER = "viewer"
  belongs_to :mindmap


  index [:kind,:mindmap_id]
  index [:kind,:email]
  index :mindmap_id

  validates_presence_of :email
  validates_inclusion_of :kind, :in => [EDITOR,VIEWER]
  validates_presence_of :mindmap
  validates_format_of :email,
    :with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/

  # 邮箱所有者
  def email_actor
    EmailActor.new(self.email)
  end

  module MindmapMethods
    def self.included(base)
      # 包括以下三类导图
      # 我协同给别人
      # 我协同给团队
      # 别人协同给我
      base.named_scope :cooperate_of_user, lambda {|user,kind|
        {:joins=>" inner join cooperations on mindmaps.id = cooperations.mindmap_id",
          :conditions=>"(mindmaps.user_id = #{user.id} or cooperations.email = '#{user.email}' or cooperations.email = '#{EmailActor.get_mindpin_email(user)}') and cooperations.kind = '#{kind}'"}
      }

      base.extend(ClassMethods)
      base.has_many :cooperations
    end

    # mindmap 类方法
    module ClassMethods
      # 我协同给个人
      # 我协同给团队
      def cooperate_by(user,kind)
        coos = user.mindmaps.map do |mindmap|
          Cooperation.find_all_by_mindmap_id_and_kind(mindmap.id,kind)
        end.flatten
        coos.map{|coo|Mindmap.find_by_id(coo.mindmap_id)}.compact.uniq
      end

      # 协同给我
      def cooperate_with(user,kind)
        email = user.email
        mindpin_email = EmailActor.get_mindpin_email(user)
        email_coos = Cooperation.find_all_by_email_and_kind(email,kind)
        mindpin_email_coos = Cooperation.find_all_by_email_and_kind(mindpin_email,kind)
        coos = email_coos | mindpin_email_coos
        coos.map{|coo|Mindmap.find_by_id(coo.mindmap_id)}.compact.uniq
      end

      # 包括以下三类导图
      # 我协同编辑给别人
      # 我协同编辑给团队
      # 别人协同编辑给我
      def cooperate_edit_of_user(user)
        #        self.cooperate_of_user(user,Cooperation::EDITOR).uniq.compact
        cooperate_by(user,Cooperation::EDITOR) | cooperate_with(user,Cooperation::EDITOR)
      end

      # 包括以下三类导图
      # 我协同查看给别人
      # 我协同查看给团队
      # 别人协同查看给我
      def cooperate_view_of_user(user)
        #        self.cooperate_of_user(user,Cooperation::VIEWER).uniq.compact
        cooperate_by(user,Cooperation::VIEWER) | cooperate_with(user,Cooperation::VIEWER)
      end
    end

    # 导图的协同编辑 邮件列表
    def cooperate_edit_email_list
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{EDITOR}'")
      coos.map{|coo|coo.email}.flatten.uniq
    end

    # 导图的协同查看 邮件列表
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
      coos = Cooperation.find_all_by_mindmap_id_and_kind(self.id,EDITOR).flatten
      email_list = coos.map{|coo|coo.email}
      email_list = [self.user.email,email_list].flatten if !!self.user
      EmailActor.new(user.email).belonging?(email_list)
    rescue
      false
    end

    # user 对 这个导图 有协同查看的权限
    def cooperate_view?(user)
      coos = Cooperation.find_all_by_mindmap_id_and_kind(self.id,VIEWER).flatten
      email_list = coos.map{|coo|coo.email}
      email_list = [self.user.email,email_list].flatten if self.user
      EmailActor.new(user.email).belonging?(email_list)
    rescue
      false
    end

  end

  module UserMethods
    # 被别人协同编辑的导图（不包括团队协同）
    def cooperate_edit_mindmaps
      email_coos = Cooperation.find_all_by_email_and_kind(self.email,EDITOR).flatten
      mindpin_email_coos = Cooperation.find_all_by_email_and_kind(EmailActor.get_mindpin_email(self),EDITOR).flatten
      coos = email_coos | mindpin_email_coos
      mindmaps = coos.map{|coo|coo.mindmap}.compact
      mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id && !!mindmap.user}
    end

    # 被别人协同查看的导图（不包括团队协同）
    def cooperate_view_mindmaps
      email_coos = Cooperation.find_all_by_email_and_kind(self.email,VIEWER).flatten
      mindpin_email_coos = Cooperation.find_all_by_email_and_kind(EmailActor.get_mindpin_email(self),VIEWER).flatten
      coos = email_coos | mindpin_email_coos
      mindmaps = coos.map{|coo|coo.mindmap}.compact
      mindmaps = mindmaps.select{|mindmap|mindmap.user_id != self.id  && !!mindmap.user}
      mindmaps.select{|mindmap|mindmap.private}
    end
  end


end
