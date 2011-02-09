class MindmapNode
  attr_reader :nokogiri_node
  def initialize(mindmap_document,nokogiri_node)
    @mindmap_document = mindmap_document
    @nokogiri_node = nokogiri_node
  end

  # get id
  def id
    @nokogiri_node['id']
  end

  # set id
  def id=(id)
    @nokogiri_node['id'] = id
  end

  def title
    @nokogiri_node['title']
  end

  def title=(title)
    @nokogiri_node['title'] = title
  end

  def closed
    @nokogiri_node['closed'] == "true"
  end

  def closed=(closed)
    value = closed ? "true" : "false"
    @nokogiri_node['closed'] = value
  end

  def image
    MindmapNodeImage.new(@nokogiri_node)
  end

  def image=(image_hash)
    mni = MindmapNodeImage.new(@nokogiri_node)
    mni.url = image_hash[:url]
    mni.width = image_hash[:width]
    mni.height = image_hash[:height]
  end

  def note
    MindmapNodeNote.new(@mindmap_document,self)
  end

  def note=(note_text)
    MindmapNodeNote.new(@mindmap_document,self).text = note_text
  end

  # 返回最后的修改者和修改时间
  def modified
    @nokogiri_node["modified"]
  end

  def modified_email
    return @mindmap_document.mindmap.user.email if modified.nil?
    modified.split(" ")[0]
  end

  def modified_time
    return @mindmap_document.mindmap.updated_at if modified.nil?
    Time.at(modified.split(" ")[1].to_i)
  end

  # 设置最后的修改者和修改时间
  def modified=(user)
    @nokogiri_node["modified"] = "#{user.email} #{Time.now.to_i}"
  end

  # 返回直接下级子节点数组
  def children
    @nokogiri_node.xpath('./node').map{|node|MindmapNode.new(@mindmap_document,node)}
  end

  # 根据nodeid返回Node对象
  def node(node_id)
    @nokogiri_node.css("node[id='#{node_id}']").map{|node|MindmapNode.new(@mindmap_document,node)}
  end

  # 移除当前Node对象
  def remove
    @nokogiri_node.remove
  end

  # 在当前节点下插入Node对象
  def insert_node(node,index)
    children_count = children.count
    if (children_count > 0) && (children_count > index) && (index != -1)
      next_node = children[index].nokogiri_node
      next_node.add_previous_sibling node.nokogiri_node
    else
      @nokogiri_node.add_child node.nokogiri_node
    end
  end

  # 返回所有子孙节点数组
  def descendants
    @nokogiri_node.css('node').map{|node|MindmapNode.new(@mindmap_document,node)}
  end

  def struct_hash
    re=[]
    children.each do |n|
      hn={
        :id=>n.id,
        :title=>n.title,
        :closed=>n.closed,
        :pos=>n.pos,
        :children=>n.struct_hash,
        :image=>{
          :url=>n.image.url,
          :width=>n.image.width,
          :height=>n.image.height
        },
        :note=>@mindmap_document.get_note_from(n.id),
        :modified_email=>n.modified_email,
        :modified_time=>n.modified_time
      }
      re<<hn
    end
    re
  end

  def pos
    return @nokogiri_node['pos']||"right" if is_one_level_node?
  end

  def pos=(pos)
    raise "pos 值只能是 left 或者 right" if !["left","right"].include?(pos)
    @nokogiri_node.remove_attribute("pos") if !is_one_level_node?
    @nokogiri_node["pos"] = pos
  end

  def is_root_node?
    @nokogiri_node.ancestors.count == 2
  end

  def parent
    MindmapNode.new(@mindmap_document,@nokogiri_node.parent)
  end

  private
  def is_one_level_node?
    @nokogiri_node.ancestors.count == 3
  end

end
