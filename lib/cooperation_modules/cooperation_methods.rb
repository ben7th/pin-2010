module CooperationMethods
  EDITOR = "editor"
  VIEWER = "viewer"
  def self.included(base)
    base.belongs_to :mindmap

    base.index [:kind,:mindmap_id]
    base.index [:kind,:email]
    base.index :mindmap_id

    base.validates_presence_of :email
    base.validates_inclusion_of :kind, :in => [EDITOR,VIEWER]
    base.validates_presence_of :mindmap
    base.validates_format_of :email,
    :with=>/^([A-Za-z0-9_]+)([\.\-\+][A-Za-z0-9_]+)*(\@[A-Za-z0-9_]+)([\.\-][A-Za-z0-9_]+)*(\.[A-Za-z0-9_]+)$/
  end

  # 邮箱所有者
  def email_actor
    EmailActor.new(self.email)
  end
end
