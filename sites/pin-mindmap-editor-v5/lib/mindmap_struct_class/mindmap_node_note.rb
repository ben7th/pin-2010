class MindmapNodeNote
  def initialize(mindmap_document,node)
    @node = node
    @mindmap = mindmap_document.mindmap
  end

  def text
    @mindmap.node_notes[@node.id]
  end

  def text=(text)
    @mindmap.update_node_note(@node.id,text)
  end
end
