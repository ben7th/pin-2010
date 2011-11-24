module ServersFeedsLucene
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    include PathConfig
    def feeds_lucene_service_state
      pid_file_path = "/web/2010/pids/feeds_lucene_service.pid"
      ManagementUtil.check_process_by_pid_file(pid_file_path)
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
end
