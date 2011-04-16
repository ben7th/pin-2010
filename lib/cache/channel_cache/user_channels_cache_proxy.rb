# 某个用户参与的频道的向量缓存
# 该缓存中存储的是 Channel Id

class UserChannelsCacheProxy < RedisBaseProxy
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_channel_ids"
  end

  # 缓存初始化查询方法
  def xxxs_ids_db
    @user.belongs_to_channels_db.map{|channel|channel.id}
  end

  # 缓存更新规则
  # 当ChannelUser创建时，放置channel_user.channel_id到该缓存里
  # 当ChannelUser删除时，从该缓存里移除
#  RULES.add ChannelUser,:after_create do |cu|
#
#  end

  # 缓存给对象添加的方法
  # user.belongs_to_channels
end