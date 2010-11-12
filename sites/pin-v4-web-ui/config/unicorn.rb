worker_processes 3

listen '/tmp/nginx/sockets/ui_unicorn.sock', :backlog => 2048
timeout 30

pid_file = "/web/2010/pids/unicorn_pin_v4_web_ui.pid"
pid pid_file
preload_app true

before_fork do |server, worker|
  old_pid = pid_file + '.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end