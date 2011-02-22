module MindpinServiceManagementModule
  module Servers
    module MemcachedService
      # 返回 memcached 的运行状态
      def memcached_service_state
        pid_file_path = "/tmp/memcached.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def memcached_service_start?
        memcached_service_state == "正常运行"
      end

      def start_memcached_service
        memcached_sh = File.join(RAILS_ROOT,"../memcache.sh")
        `sh #{memcached_sh}`
      end

      def restart_memcached_service
        start_memcached_service
      end

      def stop_memcached_service
        `kill \` cat /tmp/memcached.pid \``
      end

      def check_stats_memcached_service
        Memcached.exec("stats").map do |line|
          [line.split(" ")[1], line.split(" ")[2]]
        end
      end

    end

    module RedisService
      REDIS_SERVICE_SH = "#{RAILS_ROOT}/../redis_service.sh"
      def redis_service_state
        pid_file_path = "/web/2010/pids/redis_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def redis_service_start?
        redis_service_state == "正常运行"
      end

      def start_redis_service
        chdir_to_root_dir{ `sh #{REDIS_SERVICE_SH} start` }
      end

      def stop_redis_service
        chdir_to_root_dir{ `sh #{REDIS_SERVICE_SH} stop` }
      end

      def restart_redis_service
        chdir_to_root_dir{ `sh #{REDIS_SERVICE_SH} restart` }
      end
    end

    module MindmapsLuceneService
      MINDMAP_LUCENE_SH = "#{RAILS_ROOT}/../mindmaps_lucene_service.sh"
      def mindmaps_lucene_service_state
        pid_file_path = "/web/2010/pids/mindmaps_lucene_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def mindmaps_lucene_service_start?
        mindmaps_lucene_service_state == "正常运行"
      end

      def start_mindmaps_lucene_service
        chdir_to_root_dir{ `sh #{MINDMAP_LUCENE_SH} start` }
      end

      def stop_mindmaps_lucene_service
        chdir_to_root_dir{ `sh #{MINDMAP_LUCENE_SH} stop` }
      end

      def restart_mindmaps_lucene_service
        chdir_to_root_dir{ `sh #{MINDMAP_LUCENE_SH} restart` }
      end
    end
  end
end
