require "project_module"

require "server_base_module"
require "servers_module"

require "worker_base_module"
class MindpinServiceManagement
  PIN_2010_PATH = File.join(File.dirname(File.expand_path(__FILE__)),"../..")

  def self.get_pid_count_by_pid_file(pid_file_path)
    return nil if !File.exist?(pid_file_path)
    `cat #{pid_file_path}`
  end

  def self.check_process_by_pid_file(pid_file_path)
    return "关闭" if !File.exist?(pid_file_path)
    res = `ps \`cat #{pid_file_path}\``
    res_lines = res.split("\n")
    return "关闭" if res_lines.count == 1
    parse_ps_line(res_lines[1])
  end

  def self.parse_ps_line(line)
    stat = line.split(" ")[2]
    return "停止或者僵死" if %w(Z T).include?(stat)
    "正常运行"
  end

  def self.chdir_to_root_dir
    Dir.chdir("#{RAILS_ROOT}/..") do
      yield
    end
  end

  def self.log_file_content(log_path,line=1000)
    `tail -#{line} #{log_path}`
  end

  extend MindpinServiceManagementModule::Project
  extend MindpinServiceManagementModule::ServerBase
  
  extend MindpinServiceManagementModule::Servers::MemcachedService
  extend MindpinServiceManagementModule::Servers::RedisService
  extend MindpinServiceManagementModule::Servers::MindmapsLuceneService
  extend MindpinServiceManagementModule::Servers::FeedsLuceneService

  extend MindpinServiceManagementModule::WorkerBase
end
