class SynchronousMessageFromTsina
  def initialize
  end

  def syn_message
    connect_users = ConnectUser.find(:all,
      :conditions=>"syn_from_connect = true and connect_type = '#{ConnectUser::TSINA_CONNECT_TYPE}'")
    connect_users.each do |cu|
      _syn_message_of(cu)
    end
  end

  private
  def _syn_message_of(cu)
    next if cu.is_oauth_invalid?
    if cu.last_syn_message_id.blank?
      _record_last_message_id(cu)
    else
      _send_feed_and_record_last_message_id(cu)
    end
  rescue Exception => ex
    p "user #{cu.user_id} 绑定的新浪账号授权失败"
  end

  def _send_feed_and_record_last_message_id(cu)
    user = cu.user
    last_syn_message_id = cu.last_syn_message_id.to_i
    result = user.tsina_weibo.user_timeline(:since_id=>last_syn_message_id)
    if result.count > 0
      result.each do |item|
        p "user #{user.id} send feed"
        user.send_say_feed(item.text)
      end
      cu.record_last_syn_message_id(result.first.id)
    end
  end

  def _record_last_message_id(cu)
    user = cu.user
    result = user.tsina_weibo.user_timeline
    if result.count > 0
      cu.record_last_syn_message_id(result.first.id)
    end
  end
end
