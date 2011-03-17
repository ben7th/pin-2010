module MindpinServiceManagementModule
  module WorkerBase
    # 包含的 worker
    Workers = ["mindmap_input_queue_worker","mindmap_image_cache_queue_worker",
      "mindmap_import_queue_worker","channel_contact_operation_queue_worker",
      "follow_operation_queue_worker","feed_operation_queue_worker"]
    # 支持的操作
    Operations = ["start",'stop']

    # 检测worker是否开启
    def worker_start?(worker_name)
      check_worker_param(worker_name)
      worker_state(worker_name) == "正常运行"
    rescue Exception=>ex
      raise ex
    end

    # worker的状态
    def worker_state(worker_name)
      check_worker_param(worker_name)
      pid_file_path = get_pid_file_path_by_worker_name(worker_name)
      check_process_by_pid_file(pid_file_path)
    rescue Exception=>ex
      raise ex
    end

    # worker的操作
    def operate_worker(worker_name,operation)
      check_worker_param(worker_name)
      check_operation_param(operation)
      `sh #{get_sh_file_path_by_worker_name(worker_name)} #{operation}`
    rescue Exception=>ex
      raise ex
    end

    def worker_log_size(worker_name)
      file_path = find_log_file_path_by_worker_name(worker_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.size(file_path)
    end

    def worker_log_mtime(worker_name)
      file_path = find_log_file_path_by_worker_name(worker_name)
      File.mtime(file_path)
    end

    def worker_log_content(worker_name)
      file_path = find_log_file_path_by_worker_name(worker_name)
      log_file_content(file_path)
    end

    private
    def check_worker_param(worker_name)
      raise "没有 #{worker_name} 这个worker" if !Workers.include?(worker_name)
    end

    def check_operation_param(operation)
      raise "没有 #{operation} 这个 operation" if !Operations.include?(operation)
    end

    # 根据 worker_name 找到 pid 文件的存放路径
    def get_pid_file_path_by_worker_name(worker_name)
      "/web/2010/pids/#{worker_name}.pid"
    end

    # 根据 worker_name 找到 sh 文件的存放路径
    def get_sh_file_path_by_worker_name(worker_name)
      File.join(MindpinServiceManagement::PIN_2010_PATH,"#{worker_name}.sh")
    end

    def find_log_file_path_by_worker_name(worker_name)
      check_worker_param(worker_name)
      "/web/2010/logs/#{worker_name}.log"
    end
  end
end
