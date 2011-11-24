#!/usr/bin/env ruby
require "#{File.dirname(File.expand_path(__FILE__))}/../../management/lib/path_config"

if ["start","stop"].include?(ARGV[0])
  p "all_resque_queue_workers #{ARGV[0]}ing..."
  PathConfig::QUEUES.each do |queue|
    Dir.chdir(File.dirname(File.expand_path(__FILE__))) do
      `./resque_queue_worker.sh #{queue} #{ARGV[0]}`
    end
  end
  p "all_resque_queue_workers #{ARGV[0]}ed"
else
  p "tip:(start|stop)"
end
