class Cooperation < ActiveRecord::Base

  set_readonly(true)
  build_database_connection("pin-mindmap-editor")

  EDITOR = "editor"
  VIEWER = "viewer"

  belongs_to :mindmap

  module MindmapMethods
    def self.included(base)
      base.has_many :cooperations
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
  end
end
