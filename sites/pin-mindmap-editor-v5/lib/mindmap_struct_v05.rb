class MindmapStructV05
  def initialize(mindmap)
    @mindmap = mindmap
    @m_doc = Nokogiri::XML(@mindmap.struct)
  end

  def struct
    @m_doc.to_s
  end

  def mindmap
    @mindmap
  end

  # 所有节点
  def nodes
    @m_doc.xpath("//node").to_a
  end

  # 所有节点的标题
  def nodes_title
    nodes.map do |node|
      _trans_xml_title(node["title"])
    end
  end

  def content
    nodes_title * ' '
  end

  # 根节点
  def root
    @m_doc.at_xpath("/mindmap/node")
  end

  # 根节点的标题
  def root_title
    return "" if root.blank?
    _trans_xml_title(root["title"])
  end

  # 除根节点外的节点
  def child_nodes
    (nodes - [root])
  end

  # 除根节点外的节点
  def child_nodes_title
    child_nodes.map do |node|
      _trans_xml_title(node["title"])
    end
  end

  # 将XML的Attribute t中的字符串转义符全部转义，这个方法的写法比较有技巧性
  # ruby里gsub的强大用法之一
  def _trans_xml_title(title)
    title.gsub(/\\./){|m| eval '"'+m+'"'}
  end

  # 重新编排 mindmap 的 struct 的结构
  def self.rebuild(mindmap)
    ms = self.new(mindmap)
    record = self._change_n_id(ms)
    mindmap.update_attribute(:struct,ms.struct)
    self._change_note_id(record)
  end

  def self._change_note_id(record)
    record.each do |r|
      if r[:note]
        r[:note].update_attribute(:local_id, r[:new_local_id])
      end
    end
  end

  def self._change_n_id(mindmap_struct)
    
    root = mindmap_struct.root
    child_nodes = mindmap_struct.child_nodes
    mindmap = mindmap_struct.mindmap

    record = []
    record << self._build_node_new_local_id(mindmap,root,0)
    child_nodes.each_with_index do |node,i|
      record << self._build_node_new_local_id(mindmap,node,i+1)
    end
    record
  end

  # 返回 {:note=>note,:new_local_id=>new_id}
  def self._build_node_new_local_id(mindmap,node,new_id)
    local_id = node["id"]
    note = mindmap.nodes.find_by_local_id(local_id)
    node["id"] = new_id.to_s
    {:note=>note,:new_local_id=>new_id}
  end
end