module MindpinServiceManagementModule
  # project_name 包括以下几个
  #       pin-user-auth
  #       pin-mev6
  #       app-mindmap-image-cache
  #       pin-bugs
  module Project
    # 操作工程的 启动，关闭，重启，usr
    # param operation 要做的操作
    #       start stop restart usr2_stop
    def operate_project(project_name,operation)
      short_name = find_short_project_name_by_project_name(project_name)
      unicorn_sh = File.join(RAILS_ROOT,"../..","unicorn.sh")
      raise "不支持 #{operation} 操作" if !["start","stop","restart","usr2_stop"].include?(operation)
      Dir.chdir("#{RAILS_ROOT}/../..") do
        `sh #{unicorn_sh} #{short_name} #{operation}`
      end
    end

    # 可能返回的值: 正常运行 关闭 停止或者僵死
    def project_state(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      check_process_by_pid_file(pid_file_path)
    end

    # 查看 工程是否正常运行
    def project_start?(project_name)
      project_state(project_name) == "正常运行"
    end

    def project_log_size(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.size(file_path)
    end

    def project_log_mtime(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def project_log_content(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      log_file_content(file_path)
    end

    def project_pid_count(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      get_pid_count_by_pid_file(pid_file_path)
    end

    private
    # 根据 工程名 找到 工程进程的 pid文件 的存放路径
    def find_pid_file_path_by_project_name(project_name)
      case project_name
      when "pin-user-auth"
        "/web/2010/pids/unicorn-user-auth.pid"
      when "pin-mev6"
        "/web/2010/pids/unicorn-mev6.pid"
      when "app-mindmap-image-cache"
        "/web/2010/pids/unicorn-mindmap-image-cache.pid"
      when "pin-bugs"
        "/web/2010/pids/unicorn-bugs.pid"
      else
        raise "#{project_name} 工程不存在"
      end
    end

    # 根据完整的工程名 找到 unicorn.sh 中对应的名字
    def find_short_project_name_by_project_name(project_name)
      case project_name
      when "pin-user-auth" then "user"
      when "pin-mev6" then "mev6"
      when "app-mindmap-image-cache" then "mindmap_image_cache"
      when "pin-bugs" then "bug"
      else
        raise "#{project_name} 工程不存在"
      end
    end
    
    def find_log_file_path_by_project_name(project_name)
      if !["pin-user-auth","pin-mev6","app-mindmap-image-cache","pin-bugs"].include?(project_name)
        raise "#{project_name} 工程不存在"
      end
      "#{MindpinServiceManagement::PIN_2010_PATH}/sites/#{project_name}/log/#{RAILS_ENV}.log"
    end
  end
end