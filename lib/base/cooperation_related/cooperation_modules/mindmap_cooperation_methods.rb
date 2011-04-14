module MindmapCooperationMethods
  def self.included(base)
    base.has_many :cooperation_users
    base.has_many :cooperation_channels
  end

  def cooperate_users
    self.cooperation_users.map do |cooperation_user|
      cooperation_user.user
    end.compact
  end

  def cooperate_channels
    self.cooperation_channels.map do |cooperation_channel|
      cooperation_channel.channel
    end.compact
  end

  def add_cooperate_users(users)
    self.reload
    cooperate_users = self.cooperate_users
    users.each do |user|
      next if cooperate_users.include?(user)
      CooperationUser.create(:mindmap=>self,:user=>user)
    end
  end
  
  def add_cooperate_channels(channels)
    self.reload
    cooperate_channels = self.cooperate_channels
    channels.each do |channel|
      next if cooperate_channels.include?(channel)
      CooperationChannel.create(:mindmap=>self,:channel=>channel)
    end
  end
  
  def remove_all_cooperate_users
    self.cooperation_users.each do |cooperation_user|
      cooperation_user.destroy
    end
  end

  def remove_all_cooperate_channels
    self.cooperation_channels.each do |cooperation_channel|
      cooperation_channel.destroy
    end
  end

  def cooperate_with_user?(user)
    return true if user && self.user == user
    return true if self.cooperate_users.include?(user)
    self.cooperate_channels.each do |channel|
      return true if channel.main_users.include?(user)
    end
    return false
  end
end