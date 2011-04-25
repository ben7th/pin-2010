module MindpinServiceManagementModule
  module Servers
    SERVERS_SH_PATH = File.join(File.dirname(File.expand_path(__FILE__)),"../../sh/service_sh")
    REDIS_CLIENT = Redis.new(:thread_safe=>true)
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
        memcached_sh = File.join(SERVERS_SH_PATH,"memcache.sh")
        Dir.chdir(SERVERS_SH_PATH){ `sh #{memcached_sh}` }
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
      REDIS_SERVICE_SH = File.join(SERVERS_SH_PATH,"redis_service.sh")
      def redis_service_state
        pid_file_path = "/web/2010/pids/redis_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def redis_service_start?
        redis_service_state == "正常运行"
      end

      def start_redis_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{REDIS_SERVICE_SH} start` }
      end

      def stop_redis_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{REDIS_SERVICE_SH} stop` }
      end

      def restart_redis_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{REDIS_SERVICE_SH} restart` }
      end

      # 返回redis的状态
      def check_redis_stats
        REDIS_CLIENT.info
      end

      # 对redis进行重置
      def redis_flush_all
        REDIS_CLIENT.flushall
      end
    end

    module MindmapsLuceneService
      MINDMAP_LUCENE_SH = File.join(SERVERS_SH_PATH,"mindmaps_lucene_service.sh")
      def mindmaps_lucene_service_state
        pid_file_path = "/web/2010/pids/mindmaps_lucene_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def mindmaps_lucene_service_start?
        mindmaps_lucene_service_state == "正常运行"
      end

      def start_mindmaps_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} start` }
      end

      def stop_mindmaps_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} stop` }
      end

      def restart_mindmaps_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} restart` }
      end
    end

    module FeedsLuceneService
      FEED_LUCENE_SH = File.join(SERVERS_SH_PATH,"feeds_lucene_service.sh")
      def feeds_lucene_service_state
        pid_file_path = "/web/2010/pids/feeds_lucene_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def feeds_lucene_service_start?
        feeds_lucene_service_state == "正常运行"
      end

      def start_feeds_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{FEED_LUCENE_SH} start` }
      end

      def stop_feeds_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{FEED_LUCENE_SH} stop` }
      end

      def restart_feeds_lucene_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{FEED_LUCENE_SH} restart` }
      end
    end

    module ResqueWebService
      RESQUE_WEB_SH = File.join(SERVERS_SH_PATH,"resque_web_service.sh")
      def resque_web_service_state
        pid_file_path = "/web/2010/pids/resque_web_service.pid"
        check_process_by_pid_file(pid_file_path)
      end

      def resque_web_service_start?
        resque_web_service_state == "正常运行"
      end

      def start_resque_web_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} start` }
      end

      def stop_resque_web_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} stop` }
      end

      def restart_resque_web_service
        Dir.chdir(SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} restart` }
      end
    end
    
  end
end
