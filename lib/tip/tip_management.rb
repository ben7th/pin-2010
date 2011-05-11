class TipManagement
  def self.load_proxy(klass)
    rules = klass.rules
    raise("#{klass} tip rules 未定义") if rules.nil?
    [rules].flatten.each do |r|
      @@rules << r
    end
  end


  def self.refresh_tip_by_rules(model,callback_type)
    @@rules.each do |r|
      if (r[:class] == model.class) && !r[callback_type].nil?
        r[callback_type].call(model)
      end
    end
  end

  @@rules = []
  TipManagement.load_proxy(UserFavFeedChangeTipProxy)
  TipManagement.load_proxy(UserBeInvitedFeedTipProxy)
  TipManagement.load_proxy(UserAddViewpointTipProxy)
  TipManagement.load_proxy(UserViewpointVoteUpTipProxy)
  # ---------- 每增加一个子proxy就配置在这里
  # 用到闭包，method_missing等一些手段，来减少冗余代码
end
