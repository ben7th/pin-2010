module CurrentUserHelper
  def current_user_is_newbie?
    logged_in? && current_user.in_feeds_count == 0
  end

  def current_user_show_new_feature_tips?
    logged_in? && !current_user_is_newbie? && current_user.unread_new_feature_tips_count > 0
  end
end
