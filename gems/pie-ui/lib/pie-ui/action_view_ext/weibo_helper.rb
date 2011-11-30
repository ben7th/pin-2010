module PieUi

  module WeiboHelper

    # 尝试返回用于获取数据的公共微博连接对象
    def public_weibo(user = nil)
      if logged_in? && current_user.has_binded_tsina?
        return current_user.tsina_weibo
      elsif !user.blank? && user.has_binded_tsina?
        return user.tsina_weibo
      else
        return User.find(1016287).tsina_weibo if RAILS_ENV=='development' # 1016287 漫品 ben7th6@sina.com
        return User.find(1009).tsina_weibo if RAILS_ENV=='production' # 1009 大灰狼果糖 ben7th@126.com
      end
    end

  end

end
