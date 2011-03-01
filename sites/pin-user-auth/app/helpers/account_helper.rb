module AccountHelper
  def account_type_str(user)
    return '未登录' if user.blank?
    case current_user.account_type
      when ConnectUser::TSINA_CONNECT_TYPE then "新浪微博账号"
      when ConnectUser::RENREN_CONNECT_TYPE then "人人网账号"
    end
  end
end
