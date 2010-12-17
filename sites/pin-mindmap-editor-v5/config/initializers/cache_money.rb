require 'cache_money'
require 'memcache'

config = YAML.load(IO.read(File.join(RAILS_ROOT, "config", "memcached.yml")))[RAILS_ENV]
$memcache = MemCache.new(config)
$memcache.servers = config['servers']

$local = Cash::Local.new($memcache)
$lock = Cash::Lock.new($memcache)
$cache = Cash::Transactional.new($local, $lock)
