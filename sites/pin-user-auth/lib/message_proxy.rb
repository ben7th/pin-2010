class MessageProxy

  def self.send_message(sender,receiver_email,content)
    raise "请填写收信人" if receiver_email.blank?
    receiver = EmailActor.get_user_by_email(receiver_email)
    raise Message::NotFoundReceiverError,'收信人不存在' if receiver.blank?
    raise Message::ForbidSendToSelfError,'不能给自己发信息' if sender.id == receiver.id
    raise Message::ForbidSendToUnfans,'收信人没有加你为联系人' if !sender.can_send_message_to?(receiver)
    begin
      Message.create!(:reader=>sender,
        :sender_email=>sender.email,:receiver_email=>receiver.email,
        :content=>content,:has_read=>false)
      Message.create!(:reader=>receiver,
        :sender_email=>sender.email,:receiver_email=>receiver.email,
        :content=>content,:has_read=>false)
    rescue Exception => ex
      raise '服务器出现异常，请稍后再试'
    end
  end

  def initialize(user)
    @user = user
    @message_vector_cache_key = "#{user.email}_message_cache"
    @unread_message_vector_cache_key = "#{user.email}_unread_message_cache"
    @redis = RedisCache.instance
  end

  # messagebox 中所有的用户
  def users
    if !@redis.exists(@message_vector_cache_key)
      reload_cache
    end
    hash_json = @redis.get(@message_vector_cache_key)
    ActiveSupport::JSON.decode(hash_json).keys.map do |email|
      EmailActor.get_user_by_email(email)
    end.compact
  end

  def messages_from(the_other_user)
    message_ids_from(the_other_user).map{|id|Message.find_by_id(id)}.compact
  end

  def unread_message_count_from(the_other_user)
    unread_message_ids_from(the_other_user).count
  end

  def message_count_from(the_other_user)
    message_ids_from(the_other_user).count
  end

  def newest_message_from(the_other_user)
    ids = message_ids_from(the_other_user)
    newest_id = ids.first
    Message.find_by_id(newest_id)
  end

  def unread_message_count
    users.map do |user|
      unread_message_count_from(user)
    end.sum
  end

  module ReadCache
    # 关于 the_other_user 的所有message id
    def message_ids_from(the_other_user)
      id_list = message_vector_cache(the_other_user)
      if id_list.nil?
        message_ids = Message.reader_is(@user).find(:all,:conditions=>_conditions(the_other_user),:order=>"id desc").map{|m|m.id}
        set_message_vector_cache(the_other_user,message_ids)
        message_ids
      else
        id_list
      end
    end

    # 关于 the_other_user 的所有未读的message id
    def unread_message_ids_from(the_other_user)
      id_list = unread_message_vector_cache(the_other_user)
      if id_list.nil?
        message_ids = Message.reader_is(@user).unread.find(:all,:conditions=>_conditions(the_other_user),:order=>"id desc").map{|m|m.id}
        set_unread_message_vector_cache(the_other_user,message_ids)
        message_ids
      else
        id_list
      end
    end
    
    def message_vector_cache(the_other_user)
      return nil if !@redis.exists(@message_vector_cache_key)
      hash_json = @redis.get(@message_vector_cache_key)
      hash_cache = ActiveSupport::JSON.decode(hash_json)
      return nil if hash_cache[the_other_user.email].blank?
      hash_cache[the_other_user.email]
    end

    def unread_message_vector_cache(the_other_user)
      return nil if !@redis.exists(@unread_message_vector_cache_key)
      hash_json = @redis.get(@unread_message_vector_cache_key)
      hash_cache = ActiveSupport::JSON.decode(hash_json)
      return nil if hash_cache[the_other_user.email].nil?
      hash_cache[the_other_user.email]
    end

    def _conditions(the_other_user)
      %`
      receiver_email = '#{the_other_user.email}'
        OR
      sender_email = '#{the_other_user.email}'
      `
    end
  end

  module EditCache
    def create_empty_message_vector_cache_if_noexists
      if !@redis.exists(@message_vector_cache_key)
        @redis.set(@message_vector_cache_key,{}.to_json)
      end
    end

    def create_empty_unread_message_vector_cache_if_noexists
      if !@redis.exists(@unread_message_vector_cache_key)
        @redis.set(@unread_message_vector_cache_key,{}.to_json)
      end
    end

    def add_to_vector_cache(the_other_user,message)
      add_to_message_vector_cache(the_other_user,message)
      add_to_unread_message_vector_cache(the_other_user,message)
    end

    # 增加一个人的某一条message到信息缓存
    def add_to_message_vector_cache(the_other_user,message)
      cache = message_vector_cache(the_other_user)
      if cache.nil?
        reload_message_cache
      else
        cache.unshift(message.id)
        set_message_vector_cache(the_other_user,cache)
      end
    end

    # 增加一个人的某一条message到未读信息缓存
    def add_to_unread_message_vector_cache(the_other_user,message)
      cache = unread_message_vector_cache(the_other_user)
      if cache.nil?
        reload_unread_message_cache
      else
        cache.unshift(message.id)
        set_unread_message_vector_cache(the_other_user,cache)
      end
    end

    def set_message_vector_cache(the_other_user,message_ids)
      create_empty_message_vector_cache_if_noexists
      hash_json = @redis.get(@message_vector_cache_key)
      hash_cache = ActiveSupport::JSON.decode(hash_json)
      hash_cache[the_other_user.email] = message_ids
      @redis.set(@message_vector_cache_key,hash_cache.to_json)
    end

    def set_unread_message_vector_cache(the_other_user,message_ids)
      create_empty_unread_message_vector_cache_if_noexists
      hash_json = @redis.get(@unread_message_vector_cache_key)
      hash_cache = ActiveSupport::JSON.decode(hash_json)
      hash_cache[the_other_user.email] = message_ids
      @redis.set(@unread_message_vector_cache_key,hash_cache.to_json)
    end

    def clear_unread_message_vector_cache(the_other_user)
      message_ids = unread_message_ids_from(the_other_user)
      set_unread_message_vector_cache(the_other_user,[])
      message_ids.each do |id|
        message = Message.find_by_id(id)
        message.update_attributes(:has_read=>true) if !!message
      end
    end
  end

  module ReloadCache
    # 重新读取并设置当前用户主体的hash缓存
    def reload_cache
      _other_users_from_db.each do |the_other_user|
        message_ids_from(the_other_user)
        unread_message_ids_from(the_other_user)
      end
      create_empty_message_vector_cache_if_noexists
      create_empty_unread_message_vector_cache_if_noexists
    end

    # 重新读取并设置当前用户主体的消息hash缓存
    def reload_message_cache
      _other_users_from_db.each do |the_other_user|
        message_ids_from(the_other_user)
      end
      create_empty_message_vector_cache_if_noexists
    end

    # 重新读取并设置当前用户主题的未读消息hash缓存
    def reload_unread_message_cache
      _other_users_from_db.each do |the_other_user|
        unread_message_ids_from(the_other_user)
      end
      create_empty_unread_message_vector_cache_if_noexists
    end

    def _other_users_from_db
      Message.find(:all,:conditions=>"reader_id = '#{@user.id}'").map{|m|m.the_other_user}.uniq
    end
  end

  include ReadCache
  include EditCache
  include ReloadCache
end
