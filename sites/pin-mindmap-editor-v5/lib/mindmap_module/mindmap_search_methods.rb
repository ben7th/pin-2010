module MindmapSearchMethods
  # 获取当前导图的相关导图
  def similar_mindmaps(maps_count=5)
    MindmapLucene.similar_mindmaps_of(self,maps_count)
  rescue Exception => ex
    p ex
    return []
  end

  # 获取当前导图的主要关键词
  def major_words(words_count=5)
    KeywordsAnalyzer.new(self.content).major_words(words_count)
  rescue Exception => ex
    p ex
    return []
  end

  def self.included(base)
    base.before_save :set_content
    base.after_save :save_lucene_index
    base.after_destroy :delete_lucene_index
    base.extend(ClassMethods)
  end

  def save_lucene_index
    MindmapLucene.index_one_mindmap(self.id)
  end

  def delete_lucene_index
    MindmapLucene.delete_index(self.id)
  end

  def set_content
    self.content = MindmapStruct.new(self).content
    return true
  end

  module ClassMethods
    def major_words_of_user(user,words_count=5)
      content = user.mindmaps.map{|m|m.content}*" "
      KeywordsAnalyzer.new(content).major_words(words_count)
    rescue Exception => ex
      p ex
      []
    end

    def similar_mindmaps_of_user(user,maps_count=5)
      MindmapLucene.similar_mindmaps_of_user(user,maps_count)
    rescue Exception => ex
      p ex
      return []
    end
  end
end