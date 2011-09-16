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
  def user_avatar_s200(user)
    logo_updated_at = user.logo_updated_at
    if(logo_updated_at.year.to_i >= 2011 && logo_updated_at.month.to_i >= 9 && logo_updated_at.day.to_i >= 20)
      avatar user,:s200
    else
      avatar user,:medium
    end
  end
end
