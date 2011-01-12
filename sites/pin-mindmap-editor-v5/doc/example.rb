# 将导图的结构解析和修改改为由以下几个类完成
# 原MindmapStruct将废弃

class Mindmap < ActiveRecord::Base
  # 取得思维导图文档解析对象实例
  def document
    Mindmap::Document.new(self)
  end

  # 取得思维导图json
  def struct_json
    document.struct_hash.to_json
  end
end

class Mindmap::Document

  def initialize(mindmap)
    # TODO
  end

  # 取得思维导图节点一维数组
  def nodes
    # TODO return [Mindmap::Node, Mindmap::Node, .., Mindmap::Node]
  end

  # 取得思维导图xml解析出的hash
  def struct_hash
    
  end
end

class Mindmap::Node
  def id
    # get id
  end

  def id=(id)
    # TODO set id
  end

  def title
  end

  def title=()
  end

  def closed
  end

  def closed=(closed)
  end

  def image
    # TODO return Mindmap::Node::Image
  end

  def image=(image_hash)
  end

  def note
    # TODO return Mindmap::Node::Note
  end

  def note=(note_text)
  end

  # 返回直接下级子节点数组
  def children
    # TODO return [Mindmap::Node, Mindmap::Node, .., Mindmap::Node]
  end

  # 根据nodeid返回Node对象
  def node(node_id)
  end

  # 移除当前Node对象
  def remove
  end

  # 在当前节点下插入Node对象
  def insert_node(node,index)
  end

  # 返回所有子孙节点数组
  def descendants
    # TODO return [Mindmap::Node, Mindmap::Node, .., Mindmap::Node]
  end

  def struct_hash
    # TODO 返回当前子树的hash
  end
  
end

class Mindmap::Node::Image
  def url
  end

  def url=(url)
  end

  def width
  end

  def width=(width)
  end

  def height
  end

  def height=(height)
  end
end

class Mindmap::Node::Note
  def text
  end

  def text=(text)
  end
end