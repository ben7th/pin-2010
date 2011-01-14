class MindmapDocument
  attr_reader :mindmap
  def initialize(mindmap)
    @mindmap = mindmap
    @nokogiri_document = Nokogiri::XML(@mindmap.struct) if !@mindmap.struct.blank?
    MindmapChangeStruct.new(mindmap).change_struct_to_new
  end

  def struct
    @nokogiri_document.to_s
  end

  def content
    @nokogiri_document.css("node").map do|node|
      node["title"]
    end*"  "
  end

  # 取得思维导图节点一维数组
  def nodes
    @nokogiri_document.css("node").map{|node|MindmapNode.new(self,node)}
  end

  # 思维导图的 根节点
  def root_node
    MindmapNode.new(self,@nokogiri_document.at_xpath("/mindmap/node"))
  end

  # 根据nodeid返回Node对象
  def node(node_id)
    node = @nokogiri_document.at_css("node[id='#{node_id}']")
    MindmapNode.new(self,node)
  end

  def revision
    @nokogiri_document.at_xpath("/mindmap")["revision"].to_i || 0
  end

  def revision=(revision)
    @nokogiri_document.at_xpath("/mindmap")["revision"] = revision.to_s
  end

  def create_node(id,title)
    node = Nokogiri::XML::Node.new('node',@nokogiri_document)
    node["id"] = id
    node["title"] = title
    node["closed"] = "false"
    MindmapNode.new(self,node)
  end

  # 取得思维导图xml解析出的hash
  def struct_hash
    root = root_node
    shash={
      :id=>root.id,
      :children=>root.struct_hash,
      :title=>root.title,
      :revision=>revision,
      :image=>{
        :url=>root.image.url,
        :height=>root.image.height,
        :width=>root.image.width
      },
      :note=>get_note_from(root.id)
    }
    shash
  end

  def get_note_from(id)
    @node_note_hash ||= @mindmap.node_notes
    @node_note_hash[id] || ""
  end

  def init_default_struct
    default_str = "<mindmap ver='0.5' revision='0'><node/></mindmap>"
    @nokogiri_document = Nokogiri::XML(default_str)

    root_node.id    = randstr(8)
    root_node.title = @mindmap.title    

    @mindmap.struct = struct
  end
end
