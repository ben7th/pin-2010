module MindmapSearchMethods
  def relative_mindmaps
    return [] if self.rank.to_i == 0
    return MindmapLucene.relative_mindmaps(self.major_words*" & ",5)
    rescue Exception => ex
      p ex
      return []
  end

  def major_words
    TopicKeyword.major_words(self.content||"")
  end

  def self.included(base)
    base.before_save :set_content
    base.after_save :create_lucene_index
    base.after_destroy :delete_lucene_index
  end

  def create_lucene_index
    MindmapLucene.index_one_mindmap(self.id)
  end

  def delete_lucene_index
    MindmapLucene.delete_index(self.id)
  end

  def set_content
    self.content = _struct_to_content
    return true
  end

  # 从 struct 中 提取所有的节点标题
  def _struct_to_content
    ms = MindmapStruct.new(self)
    ms.nodes_title*' '
  end
end