module ServersMindmapsLucene
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    MINDMAP_LUCENE_SH = File.join(ServerManagement::SERVERS_SH_PATH,"mindmaps_lucene_service.sh")
    def mindmaps_lucene_service_state
      pid_file_path = "/web/2010/pids/mindmaps_lucene_service.pid"
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def mindmaps_lucene_service_start?
      mindmaps_lucene_service_state == "正常运行"
    end

    def start_mindmaps_lucene_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} start` }
    end

    def stop_mindmaps_lucene_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} stop` }
    end

    def restart_mindmaps_lucene_service
      Dir.chdir(ServerManagement::SERVERS_SH_PATH){ `sh #{MINDMAP_LUCENE_SH} restart` }
    end
  end
end