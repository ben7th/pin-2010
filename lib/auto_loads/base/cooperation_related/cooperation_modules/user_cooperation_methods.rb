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
  
  def channel_cooperate_mindmaps
    channel_cooperate_mindmaps_db
  end

  def channel_cooperate_mindmaps_db
    self.belongs_to_channels_db.each do |channel|
      channel.cooperate_mindmaps_db
    end.flatten.compact
  end
end

