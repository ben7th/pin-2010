class UserTipProxy

  # 通知代理类是对一个用户的所有通知的包装
  # 查询，删除，等操作的范围都是针对这个用户的所有通知
  def initialize(user)
    @user = user
    @key = "user_#{@user.id}_tip"
    @redis_cache = UserTipRedisCache.new(@key)
  end

  def redis_cache
    @redis_cache
  end

  #--------------组织数据相关方法
  #----------

  # 获得通知总数
  def tips_count
    clear_tips_of_disabled_kinds
    @redis_cache.count
  end

  # 这里只组织数据，不删除任何失效条目。
  # 否则会出现 tips_count 和 tips 数量上不一致的情况。
  # 显示在前端的效果就是 看见有通知数量提示，但却没有显示。体验不好。
  # 而且会导致这些本身有问题的key，永远不能被用户操作或者系统自动清除，白白占据内存
  # 这类异常，留给后续的层，比如helper去处理。
  #
  # 获得所有通知的UserTip对象数组，按时间顺序倒序排序
  def tips
    clear_tips_of_disabled_kinds
    
    @redis_cache.all.map {|tip_id, tip_data|
      UserTip.build(@user, tip_id, tip_data)
    }.compact.sort{|a,b|b.time<=>a.time}
  end

  # 获得人际关系相关的tips数组
  def contacts_tips
    kinds = [UserTip::BE_FOLLOWED]
    tips.select{|tip|kinds.include?(tip.kind)}
  end


  #--------------------------------
  #-------获取UserTip对象的相关方法-----------------

  def get_tip_by_id(tip_id)
    tip_data = @redis_cache.get tip_id
    return nil if tip_data.blank?
    UserTip.build(@user, tip_id, tip_data)
  end

  def remove_tip_by_id(tip_id)
    @redis_cache.remove(tip_id)
  end

  #---------------------------
  #----通知类型相关方法

  # 清理已经关闭的类型的通知
  def clear_tips_of_disabled_kinds
    will_be_removed_ids = []
    enabled_kinds = UserTipProxy.enabled_kinds
    @redis_cache.all.each do |tip_id, tip_data|
      if !enabled_kinds.include?(tip_data["kind"])
        will_be_removed_ids << tip_id
      end
    end
    will_be_removed_ids.each{|id|@redis_cache.remove(id)}
  end

  # 目前生效的通知类型
  def self.enabled_kinds
    @@enabled_kinds||=[]
  end

  # 增加通知类型
  def self.add_enabled_kinds(kind)
    self.enabled_kinds.push(kind)
    self.enabled_kinds.uniq!
  end

  # 清除所有通知
  def remove_all_tips
    @redis_cache.remove_all
  end

  #-----------------------
  #---规则定义相关方法

  # 取得所有规则
  def self.rules
    @@rules||=[]
  end

  # 增加规则
  def self.add_rules(rules)
    @@rules||=[]
    [rules].flatten.each do |rule|
      @@rules << rule
    end
  end


  # 给User类添加的实例方法
  def self.funcs
    {
      :class=> User,
      :tip_proxy=>Proc.new{|user|
        UserTipProxy.new(user)
      },
      :tips=>Proc.new{|user|
        tip_proxy.tips
      },
      :contacts_tips=>Proc.new{|user|
        tip_proxy.contacts_tips
      },
      :tips_count=>Proc.new{|user|
        tip_proxy.tips_count
      },
      :get_tip_by_id=>Proc.new{|user,tip_id|
        tip_proxy.get_tip_by_id(tip_id)
      }
    }
  end

  
  extend QueueMethods

  # 加载通知规则
  include BeFollowedMethods
end
