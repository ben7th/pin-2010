module ServersMemcached
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # 返回 memcached 的运行状态
    def memcached_service_state
      pid_file_path = "/tmp/memcached.pid"
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def memcached_service_start?
      memcached_service_state == "正常运行"
    end

    def start_memcached_service
      memcached_sh = File.join(ServerManagement::SERVERS_SH_PATH,"memcache.sh")
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{memcached_sh}` }
    end

    def restart_memcached_service
      start_memcached_service
    end

    def stop_memcached_service
      `kill \` cat /tmp/memcached.pid \``
    end

    def check_stats_memcached_service
      MemcachedStatus.exec("stats").map do |line|
        [line.split(" ")[1], line.split(" ")[2]]
      end
    end
  end
end

