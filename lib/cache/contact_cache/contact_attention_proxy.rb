class ContactAttentionProxy
  def initialize(user)
    @user = user
    @email = user.email
    @mindpin_email = EmailActor.get_mindpin_email(user)
    @fans_contacts_vector_key = "fans_contacts_vector_#{@email}"
    @followings_contacts_vector_key = "followings_contacts_vector_#{@email}"
    @refresh_newest_fans_id_cache_key = "refresh_newest_fans_id_#{@email}"
    @redis = RedisCache.instance
  end

  module Followings
    # 尝试获取当前用户关注的 contact
    # 读缓存或者读数据库
    def followings_contacts
      _followings_contacts_id_list.map { |id| Contact.find_by_id(id) }.compact
    end

    module Read
      def _followings_contacts_id_list
        _id_list = followings_contacts_vector_cache
        return _id_list if !_id_list.nil?

        # _id_list is nil 缓存无效
        re = Contact.find(:all,:conditions=>"user_id = #{@user.id}",:order=>"id desc").map{|c| c.id} # 读数据库
        set_followings_contacts_vector_cache(re)
        return re
      end

      # 获取 当前用户 关注的用户 contact 的 id-list 的向量缓存
      def followings_contacts_vector_cache
        return nil if !@redis.exists(@followings_contacts_vector_key)
        id_list_json = @redis.get(@followings_contacts_vector_key)
        ActiveSupport::JSON.decode(id_list_json)
      end
    end

    module Edit
      # 把新的contact_id添加到 followings 向量缓存的头部
      # 该向量缓存不限制长度
      def add_to_followings_contacts_vector_cache(contact_id)
        cache = followings_contacts_vector_cache
        if cache.nil?
          _followings_contacts_id_list
        else
          cache.unshift(contact_id)
          set_followings_contacts_vector_cache(cache)
        end
      end

      # 删除联系人的时候，同时删除对应的向量缓存
      def delete_from_followings_contacts_vector_cache(contact_id)
        cache = followings_contacts_vector_cache
        if !cache.nil?
          cache.delete(contact_id)
          set_followings_contacts_vector_cache(cache)
        end
      end

      # 重新设置 followings 向量缓存
      def set_followings_contacts_vector_cache(id_list)
        @redis.set(@followings_contacts_vector_key,id_list.to_json)
      end
    end

    include Read
    include Edit
  end

  module Fans
    # 尝试获取当前用户的fans
    # 读缓存或者读数据库
    def fans_contacts
      _fans_contacts_id_list.map { |id| Contact.find_by_id(id)}.compact
    end

    def new_fans_ids(current_id = nil)
      current_id = newest_fans_id if current_id.nil?
      _fans_contacts_id_list.select{|id|id>(current_id.to_i)}
    end
    
    module Read

      def newest_fans_id
        if !@redis.exists(@refresh_newest_fans_id_cache_key)
          refresh_newest_fans_id
        end
        @redis.get(@refresh_newest_fans_id_cache_key).to_i
      end

      # 获取所有关注者（关注当前用户的其他用户）的 id-list 的向量缓存
      def fans_contacts_vector_cache
        return nil if !@redis.exists(@fans_contacts_vector_key)
        id_list_json = @redis.get(@fans_contacts_vector_key)
        ActiveSupport::JSON.decode(id_list_json)
      end

      def _fans_contacts_id_list
        _id_list = fans_contacts_vector_cache

        return _id_list if !_id_list.nil?

        # _id_list is nil 缓存无效
        re = Contact.find(:all,:conditions=>"email = '#{@email}' or email = '#{@mindpin_email}' ",:order=>"id desc").map{|c| c.id} # 读数据库
        set_fans_contacts_vector_cache(re)
        return re
      end
    end

    module Edit
      def refresh_newest_fans_id
        id = _fans_contacts_id_list.first || 0
        @redis.set(@refresh_newest_fans_id_cache_key,id)
      end

      # 把新的contact_id添加到 fans 向量缓存的头部
      # 该向量缓存不限制长度
      def add_to_fans_contacts_vector_cache(contact_id)
        cache = fans_contacts_vector_cache
        if cache.nil?
          _fans_contacts_id_list
        else
          cache.unshift(contact_id)
          set_fans_contacts_vector_cache(cache)
        end
      end

      # 删除联系人的时候，同时删除对应的向量缓存
      def delete_from_fans_contacts_vector_cache(contact_id)
        cache = fans_contacts_vector_cache
        if !cache.nil?
          cache.delete(contact_id)
          set_fans_contacts_vector_cache(cache)
        end
      end

      # 重新设置 fans 向量缓存
      def set_fans_contacts_vector_cache(id_list)
        @redis.set(@fans_contacts_vector_key,id_list.to_json)
      end
    end

    include Read
    include Edit
  end

  module ContactMethods
    def self.included(base)
      base.after_create :add_fans_contacts_vector
      base.before_destroy :delete_fans_contacts_vector

      base.after_create :add_followings_contacts_vector
      base.before_destroy :delete_followings_contacts_vector
    end

    def add_fans_contacts_vector
      cap = ContactAttentionProxy.new(EmailActor.get_user_by_email(self.email))
      cap.add_to_fans_contacts_vector_cache(self.id)
      return true
    end

    def delete_fans_contacts_vector
      cap = ContactAttentionProxy.new(EmailActor.get_user_by_email(self.email))
      cap.delete_from_fans_contacts_vector_cache(self.id)
      return true
    end

    def add_followings_contacts_vector
      cap = ContactAttentionProxy.new(self.user)
      cap.add_to_followings_contacts_vector_cache(self.id)
      return true
    end

    def delete_followings_contacts_vector
      cap = ContactAttentionProxy.new(self.user)
      cap.delete_from_followings_contacts_vector_cache(self.id)
      return true
    end
    
  end

  include Fans
  include Followings
end
