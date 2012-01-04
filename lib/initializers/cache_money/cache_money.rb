# 加载cache_money配置

begin
  require 'memcache'
  require 'cache_money'

  config = case Rails.env
    when 'development'
      {
        :ttl       => 604800,
        :namespace => 'development',
        :sessions  => false,
        :debug     => true,
        :servers   => 'localhost:11211'
      }
    when 'production'
      {
        :ttl       => 604800,
        :namespace => 'production',
        :sessions  => false,
        :debug     => false,
        :servers   => 'localhost:11211'
      }
    end

  if Rails.env.test?
    $memcache = Cash::Mock.new
    p ">>>>> 当前为测试环境，$memcache = Cash::Mock.new"
  else
    $memcache = MemCache.new(config)
  end

  $memcache.servers = config[:servers]

  $local  = Cash::Local.new($memcache)
  $lock   = Cash::Lock.new($memcache)
  $cache  = Cash::Transactional.new($local, $lock)

  p '>>>>> LOAD cache-money CONFIG'

  class ActiveRecord::Base
    is_cached :repository => $cache
  end
  
rescue Exception => ex
  p "#{ex.message}，cache-money LOAD FAILED"
end