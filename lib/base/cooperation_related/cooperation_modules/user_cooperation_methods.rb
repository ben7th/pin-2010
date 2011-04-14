module UserCooperationMethods
  def self.included(base)
    base.has_many :cooperation_users,:order=>"id desc"
  end

  # 被别人协同的导图（不包括频道协同）
  def cooperate_mindmaps_db
    self.cooperation_users.map do |cooperation_user|
      cooperation_user.mindmap
    end.compact
  end
end

