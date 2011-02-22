require 'socket'

# stats
# stats reset
# stats malloc
# stats maps
# stats sizes
# stats slabs
# stats items
# stats cachedump slab_id limit_num
# stats detail [on|off|dump]

class Memcached
  class << self
    def open(host, port)
      s = TCPSocket.open(host, port)
      yield s if block_given?
    ensure
      s.close if s
    end

    def command(command_string, s)
      s.send(command_string + "\r\n", 0)
      buff = []
      until ["END", "OK", "DELETE", "ERROR"].include?(line = s.gets.strip) do
        buff << line
      end
      buff
    end

    def exec(command_string, host = "localhost", port = 11211)
      open(host, port) do |socket|
        command(command_string, socket).each {|line| puts line }
      end
    end

    def cache_stats(host = "localhost", port = 11211)
      cache_objects = {}
      open(host, port) do |socket|
        slabs = []
        command("stats items", socket).each do |line|
          slab_id = line.split[1].split(":")[1].to_i
          slabs << slab_id unless slabs.include?(slab_id)
        end
        slabs.each do |slab_id|
          puts "browse slab #{slab_id}..."
          command("stats cachedump #{slab_id} 0", socket).each do |item|
            key = item.split[1].split("/")[0].to_s
            cache_objects.include?(key) ? cache_objects[key] += 1 : cache_objects[key] = 1
          end
        end
      end
      cache_objects.each_pair {|key, value| puts "#{key} : #{value}"}
    end
  end
end
  
if ARGV.size == 0
  Memcached.cache_stats
else
  Memcached.exec(ARGV.join(" "))
end
