class Cooperation < ActiveRecord::Base

  EDITOR = "editor"
  VIEWER = "viewer"

  belongs_to :mindmap
  belongs_to :user,:foreign_key=>"email",:primary_key=>"email"

  validates_presence_of :user
  validates_inclusion_of :kind, :in => [EDITOR,VIEWER]
  validates_presence_of :mindmap

  module MindmapMethods
    # 协同编辑成员
    def cooperate_editors
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{EDITOR}'")
      users = coos.map{|coo|User.find_by_email(coo.email)}
      users << self.user
      users
    end

    # 协同查看成员
    def cooperate_viewers
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{VIEWER}'")
      users = coos.map{|coo|User.find_by_email(coo.email)}
      users << self.user
      users
    end

    # 增加协同编辑成员
    def add_cooperate_editor(user_or_email)
      user = (user_or_email.class == String) ? User.find_by_email(user_or_email) : user_or_email
      return if !!Cooperation.find_by_email_and_mindmap_id(user.email,self.id)
      Cooperation.create(:user=>user,:mindmap=>self,:kind=>EDITOR)
    end
    
    # 删除协同编辑成员
    def remove_cooperate_editor(user_or_email)
      email = (user_or_email.class == String) ? user_or_email : user_or_email.email
      coos = Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,EDITOR)
      coos.each{|coo|coo.destroy}
    end

    # 增加协同查看成员
    def add_cooperate_viewer(user_or_email)
      user = (user_or_email.class == String) ? User.find_by_email(user_or_email) : user_or_email
      return if !!Cooperation.find_by_email_and_mindmap_id(user.email,self.id)
      Cooperation.create(:user=>user,:mindmap=>self,:kind=>VIEWER)
    end

    # 删除协同查看成员
    def remove_cooperate_viewer(user_or_email)
      email = (user_or_email.class == String) ? user_or_email : user_or_email.email
      coos = Cooperation.find_all_by_email_and_mindmap_id_and_kind(email,self.id,VIEWER)
      coos.each{|coo|coo.destroy}
    end

    # user 对 这个导图 有协同编辑的权限
    def cooperate_edit?(user)
      return false if !user
      return true if self.user == user
      Cooperation.find_all_by_email_and_mindmap_id_and_kind(user.email,self.id,EDITOR).count != 0
    end

    def cooperate_editors_email_list
      coos = Cooperation.find(:all,:conditions=>"cooperations.mindmap_id = #{self.id} and cooperations.kind = '#{EDITOR}'")
      coos.map{|coo|coo.email}
    end

    # user 对 这个导图 有协同查看的权限
    def cooperate_view?(user)
      return false if !user
      return true if self.user == user
      Cooperation.find_all_by_email_and_mindmap_id_and_kind(user.email,self.id,VIEWER).count != 0
    end
  end

  module UserMethods
    # 被别人协同编辑的导图
    def cooperate_edit_mindmaps
      coos = Cooperation.find_all_by_email_and_kind(self.email,EDITOR)
      coos.map{|coo|coo.mindmap}
    end

    def cooperate_view_mindmaps
      coos = Cooperation.find_all_by_email_and_kind(self.email,VIEWER)
      coos.map{|coo|coo.mindmap}
    end
  end

end
