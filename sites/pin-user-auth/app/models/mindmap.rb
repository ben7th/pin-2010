class Mindmap < ActiveRecord::Base
  belongs_to :user
  set_readonly(true)
  build_database_connection("pin-mindmap-editor")

  index :user_id

  # 计算rank值
  def rank_value
    return 0.0 if self.weight < 0
    format('%.1f',(Math.log(self.weight+1)/Math.log(map_max_weight+1))*10).to_f
  end

  # 获取 map_max_weight
  def map_max_weight
    # 存放在硬盘文件上
    file_path = File.join(RAILS_ROOT,"../pin-mindmap-editor-v5","config", "map_max_weight")
    if !File.exist?(file_path)
      mmw = Mindmap.maximum("weight") || 0
      return mmw
    else
      return File.new(file_path,"r").read.to_i
    end
  end

  # 获取当前导图的主要关键词
  def major_words(words_count=5)
    KeywordsAnalyzer.new(self.content).major_words(words_count)
  rescue Exception => ex
    p ex
    return []
  end

  module UserMethods
    def mindmaps_count
      Mindmap.count(:all, :conditions => "user_id = #{self.id}")
    end
  end

  include Cooperation::MindmapMethods
end
