module AccountHelper
  def account_type_str(user)
    return '未登录' if user.blank?
    case current_user.account_type
      when ConnectUser::TSINA_CONNECT_TYPE then "新浪微博账号"
      when ConnectUser::RENREN_CONNECT_TYPE then "人人网账号"
    end
  end

  def account_setting_link(name,url,klass)
    selected = current_page?(url)

    outer_klass = ['link',klass,selected ? 'selected':'']*' '
    link_str = link_to "<div class='icon'></div>#{name}",url

    str = "<div class='#{outer_klass}'>#{link_str}</div>"

    return str
  end

  # 尝试返回尺寸为200的user头像，如果没有（头像更新于9月20日前的，则返回:medium的头像 96x96）
  def user_avatar_big(user)
    logo_updated_at = user.logo_updated_at
    if(logo_updated_at.year.to_i >= 2011 && logo_updated_at.month.to_i >= 11 && logo_updated_at.day.to_i >= 22)
      avatar user,:large
    else
      avatar user,:medium
    end
  rescue Exception => ex
    avatar user,:medium
  end

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
