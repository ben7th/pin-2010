module CurrentUserHelper
  
  def current_user_is_newbie?
    logged_in? && current_user.in_feeds_count == 0
  end

  def current_user_show_new_feature_tips?
    logged_in? && !current_user_is_newbie? && current_user.unread_new_feature_tips_count > 0
  end

  def usersign(user, sign=true, length=24)
    re = []
    if user.blank?
      re << '未知用户'
    else
      re << "#{link_to user.name,user,:class=>'bold u-name'}"
      if !user.sign.blank? && sign
        re << "<span class='quiet'>，#{h truncate_u(user.sign,length)}</span>"
      end
    end
    return re
  end

end
