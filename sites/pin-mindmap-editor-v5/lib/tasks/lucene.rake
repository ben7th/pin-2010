RAILS_ROOT ||= ENV["RAILS_ROOT"]
require(File.join(RAILS_ROOT, 'config', 'environment'))

namespace :lucene do
  desc "创建导图的索引"
  task :index_all do
    puts "=> 正在创建所有导图的索引..."
    if MindmapLucene.index_all
      puts "=> 导图索引创建完成 :)"
    else
      puts "=> 导图索引创建失败 :("
    end
  end
end