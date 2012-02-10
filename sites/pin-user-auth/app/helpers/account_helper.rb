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
    
    link_str = link_to url do
      content_tag(:div, '', :class=>'icon') +
      content_tag(:span, name)
    end

    return content_tag(:div, link_str, :class=>outer_klass)
  end

  # 尝试返回尺寸为200的user头像，如果没有（头像更新于9月20日前的，则返回:medium的头像 96x96）
  def user_avatar_big(user)
    avatar user, :large
  end
end
