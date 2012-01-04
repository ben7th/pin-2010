require 'cache_money'
require 'memcache'

module UserAutoCompeleteCache
  
  AUTO_COMPELETE_CACHE_MEMCACHED_CONFIG = {
    "production"=>
      {"ttl"=>604800, 
        "namespace"=>"user-autocompelete-cache-production",
        "debug"=>false, 
        "servers"=>"localhost:11211", 
        "sessions"=>false}, 
    "development"=>
        {"ttl"=>604800, 
          "namespace"=>"user-autocompelete-cache-production",
          "debug"=>false, 
          "servers"=>"localhost:11211", 
          "sessions"=>false}, 
    "test"=>
      {"ttl"=>604800, 
        "namespace"=>"user-autocompelete-cache-production",
        "debug"=>false, 
        "servers"=>"localhost:11211", 
        "sessions"=>false}}[Rails.env]

  def self.included(base)
    base.send(:extend,ClassMethods)
    base.before_save :exprie_autocompelete_cache
    base.before_destroy :exprie_autocompelete_cache
  end

  # 当用户 name 改变时
  # 删除 old name 对应的缓存
  # 增加 new name 对应的缓存
  def exprie_autocompelete_cache
    if self.name_changed?
      old_name = self.name_change.first
      new_name = self.name_change.last
      # 旧名字 对应的 全部删掉
      old_prefixs = self.class.split_prefixs(old_name)
      old_prefixs.each do |str|
        key = self.class.str_to_autocomplete_cache_key(str)
        user_ids = self.class.autocompelete_cache.get(key) || []
        user_ids.delete(self.id)
        self.class.autocompelete_cache.set(key,user_ids)
      end
      # 新名字 对应的 全部增加
      new_prefixs = self.class.split_prefixs(new_name)
      new_prefixs.each do |str|
        key = self.class.str_to_autocomplete_cache_key(str)
        user_ids = self.class.autocompelete_cache.get(key) || []
        user_ids << self.id
        user_ids.uniq!
        self.class.autocompelete_cache.set(key,user_ids)
      end
    end
    return true
  end

  # 对一个用户做 自动完成 所需的缓存
  def bulid_autocompelete_cache
    user_name_prefixs = self.class.split_prefixs(self.name)
    user_email_prefixs = self.class.split_prefixs(self.email)
    user_prefixs = user_name_prefixs | user_email_prefixs
    
    user_prefixs.each do |str|
      key = self.class.str_to_autocomplete_cache_key(str)
      value = self.class.autocompelete_cache.get(key) || []
      value << self.id
      value.uniq!
      self.class.autocompelete_cache.set(key,value)
    end
  end

  module ClassMethods

    def autocompelete_cache
      @autocompelete_cache ||= (
      memcache = MemCache.new(AUTO_COMPELETE_CACHE_MEMCACHED_CONFIG)
      memcache.servers = AUTO_COMPELETE_CACHE_MEMCACHED_CONFIG['servers']
      
      local = Cash::Local.new(memcache)
      lock = Cash::Lock.new(memcache)
      Cash::Transactional.new(local, lock)
    )
    end

    # 给所有用户做 自动完成 所需缓存
    def bulid_all_autocompelete_cache
      users = User.all
      total_count = users.count
      t_1 = Time.now
      users.each_with_index do |user,index|
        p "缓存 user #{index+1}/#{total_count}"
        user.bulid_autocompelete_cache
      end
      t_2 = Time.now
      p t_2 - t_1
    end

    # 根据 前缀内容 从缓存中找到对应用户
    def fetch_str_cache(str,options)
      return [] if str.blank?
      str = str.strip
      str = str.gsub(" ","+")
      key = self.str_to_autocomplete_cache_key(str)
      user_ids = self.autocompelete_cache.get(key) || []
      limit = options[:limit]
      user_ids = user_ids[0...limit]
      User.find :all,:conditions=>"users.id in (#{user_ids*","})"
#      user_ids.map{|user_id|User.find user_id}
    end

    # 缓存的 key 的具体形态
    def str_to_autocomplete_cache_key(str)
      "userautocomplete/#{str}"
    end

    # 举例 "abc"=>["a","ab","abc"]
    # 举例 "大家好"=>["大","大家","大家好"]
    def split_prefixs(str)
      str_arr = str.split('')
      results = []
      str_arr.each_with_index do |str, index|
        prefix_arr = str_arr[0..index]
        results << prefix_arr*""
      end
      return results
    end
  end
end