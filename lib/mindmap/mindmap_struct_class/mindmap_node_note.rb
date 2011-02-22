class MindmapNodeNote
  def initialize(mindmap_document,node)
    @node = node
    @mindmap = mindmap_document.mindmap
  end

  def text
    @mindmap.node_notes[@node.id]
  end

  def text=(text)
    if text!=''&&text!='<br>'
      # 创建或者更新
      @mindmap.update_node_note(@node.id,text)
    else
      # 删除
      @mindmap.destroy_node_note(@node.id)
    end
  end
end
