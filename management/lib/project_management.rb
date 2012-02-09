class ProjectManagement
  
  class << self
    include PathConfig

    # 操作工程的 启动，关闭，重启，usr
    # param operation 要做的操作
    #       start stop restart usr2_stop
    def operate(project_name,operation)
      short_name = find_short_project_name_by_project_name(project_name)
      unicorn_sh = File.join(UNICORN_SH_PATH,"unicorn.sh")
      raise "不支持 #{operation} 操作" if !["start","stop","restart","usr2_stop"].include?(operation)
      Dir.chdir(UNICORN_SH_PATH) do
        `sh #{unicorn_sh} #{short_name} #{operation}`
      end
    end

    # 可能返回的值: 正常运行 关闭 停止或者僵死
    def state(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    # 查看 工程是否正常运行
    def start?(project_name)
      state(project_name) == "正常运行"
    end

    def log_size(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.size(file_path)
    end

    def log_mtime(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def log_content(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      ManagementUtil.log_file_content(file_path)
    end

    def pid_count(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      ManagementUtil.get_pid_count_by_pid_file(pid_file_path)
    end

    private
    # 根据完整的工程名 找到 unicorn.sh 中对应的名字
    def find_short_project_name_by_project_name(project_name)
      case project_name
      when "pin-user-auth" then "user"
      when "pin-mev6" then "mev6"
      when "pin-uni-schedule" then "schedule"
      when "pin-products" then "products"
      else
        raise "#{project_name} 工程不存在"
      end
    end

    # 根据 工程名 找到 工程进程的 pid文件 的存放路径
    def find_pid_file_path_by_project_name(project_name)
      case project_name
      when "pin-user-auth"
        "/web/2010/pids/unicorn-user-auth.pid"
      when "pin-mev6"
        "/web/2010/pids/unicorn-mev6.pid"
      when "pin-uni-schedule"
        "/web/2010/pids/unicorn-uni-schedule.pid"
      when "pin-products"
        "/web/2010/pids/unicorn-products.pid"
      else
        raise "#{project_name} 工程不存在"
      end
    end

    def find_log_file_path_by_project_name(project_name)
      if !["pin-user-auth","pin-mev6","pin-uni-schedule","pin-products"].include?(project_name)
        raise "#{project_name} 工程不存在"
      end
      File.join(PIN_2010_PATH,"sites/#{project_name}/log/#{Rails.env}.log")
    end
  end
end
