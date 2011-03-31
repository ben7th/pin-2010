class NewsMetal < BaseMetal
  def self.routes
    {:method=>'GET',:regexp=>/^\/news\/unread_count/}
  end

  def self.deal(hash)
    env = hash[:env]
    current_user = self.current_user(env)
    newsfeed_ids = current_user.news_feed_proxy.newsfeed_ids
    new_fans_ids = NewestFansProxy.new(current_user).newest_fans_ids
    unread_messages_count = MessageProxy.new(current_user).unread_message_count
    json = {:feed=>newsfeed_ids.count,:attention=>new_fans_ids.count,:message=>unread_messages_count}.to_json
    return [200, {"Content-Type" => "text/x-json"}, [json]]
  rescue Exception=>ex
    p ex
    return [500, {"Content-Type" => "text/plain"}, [ex.message]]
  end
end