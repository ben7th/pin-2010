module MindmapSearchMethods
  def relative_mindmaps
    return [] if self.rank.to_i == 0
      mindmaps = Mindmap.search(self.major_words*"|",:match_mode => :boolean)
    return (mindmaps-[self])[0...5]
    rescue Exception => ex
      return []
  end

  def major_words
    TopicKeyword.major_words(self.content||"")
  end

  def self.included(base)
    base.before_save :set_content
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