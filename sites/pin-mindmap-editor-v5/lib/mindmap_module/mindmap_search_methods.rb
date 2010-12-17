module MindmapSearchMethods
  def relative_mindmaps
    return [] if self.rank.to_i == 0
    mindmaps = MindmapLucene.relative_mindmaps(self.major_words*" & ",6)
    mindmaps = mindmaps.select{|mindmap|mindmap != self}[0..4]
    mindmaps
    rescue Exception => ex
      p ex
      return []
  end

  def major_words
    TopicKeyword.major_words(self.content||"")
  rescue Exception => ex
    p ex
    return []
  end

  def self.included(base)
    base.before_save :set_content
    base.after_save :create_lucene_index
    base.after_destroy :delete_lucene_index
    base.extend(ClassMethods)
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

  module ClassMethods
    def major_words_of_user(user,count=5)
        content = Mindmap.of_user_id(user.id).map{|mindmap|mindmap.content}*" "
        TopicKeyword.major_words(content,count)
      rescue Exception => ex
        p ex
        []
    end

    def relative_mindmaps_of_user(user,count=5)
      query = major_words_of_user(user,20)*" "
      mindmaps_count = Mindmap.of_user_id(user.id).count
      count = count + mindmaps_count
      mindmaps = MindmapLucene.relative_mindmaps(query,count)
      mindmaps.select{|mindmap|mindmap.user_id != user.id}[0..4]
    rescue Exception => ex
      p ex
      return []
    end
  end
end