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
  end

  def save_lucene_index
    if self.instance_variable_get(:@skip_hook) != "skip"
      MindmapLucene.index_one_mindmap(self.id)
    end
  end

  def delete_lucene_index
    MindmapLucene.delete_index(self.id)
  end

  def set_content
    if self.instance_variable_get(:@skip_hook) != "skip"
      self.content = MindmapDocument.new(self).content
    end
    return true
  end

  def relative_content
    query = self.major_words*" "
    GoogleSearch.new(query).relative_content
  end
end