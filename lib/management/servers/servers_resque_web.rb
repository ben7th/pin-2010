module ServersResqueWeb
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    RESQUE_WEB_SH = File.join(ServerManagement::SERVERS_SH_PATH,"resque_web_service.sh")
    def resque_web_service_state
      pid_file_path = "/web/2010/pids/resque_web_service.pid"
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def resque_web_service_start?
      resque_web_service_state == "正常运行"
    end

    def start_resque_web_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} start` }
    end

    def stop_resque_web_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} stop` }
    end

    def restart_resque_web_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{RESQUE_WEB_SH} restart` }
    end
  end
end
