module MindpinServiceManagementModule
  module ServerBase
    # 包含的server
    Servers = ['memcached_service','redis_service','mindmaps_lucene_service','feeds_lucene_service','resque_web_service']

    # 检测服务是否开启
    def server_start?(server_name)
      check_server_name_param(server_name)
      eval("#{server_name}_start?")
    rescue Exception=>ex
      raise ex
    end

    # 服务的状态
    def server_state(server_name)
      check_server_name_param(server_name)
      eval("#{server_name}_state")
    end

    # 服务的操作
    def operate_server(server_name,operation)
      check_server_name_param(server_name)
      eval("#{operation}_#{server_name}")
    rescue Exception=>ex
      raise ex
    end

    def server_log_size(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.size(file_path)
    end

    def server_log_mtime(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def server_log_content(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      log_file_content(file_path)
    end

    def server_pid_count(server_name)
      file_path = find_pid_file_path_by_server_name(server_name)
      get_pid_count_by_pid_file(file_path)
    end

    private
    def check_server_name_param(server_name)
      raise "没有 #{server_name} 这个 server_name" if !Servers.include?(server_name)
    end

    def find_log_file_path_by_server_name(server_name)
      if !['redis_service','mindmaps_lucene_service','feeds_lucene_service','resque_web_service'].include?(server_name)
        raise "#{server_name} 这个 server_name 没有日志"
      end
      "/web/2010/logs/#{server_name}.log"
    end

    def find_pid_file_path_by_server_name(server_name)
      if server_name == "memcached_service"
        return "/tmp/memcached.pid"
      end
      return "/web/2010/pids/#{server_name}.pid"
    end
  end
end
