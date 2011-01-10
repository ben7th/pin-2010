class MindmapStruct
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
    @m_doc.xpath("//N").to_a
  end

  # 所有节点的标题
  def nodes_title
    nodes.map do |node|
      _trans_xml_title(node["t"])
    end
  end

  def content
    nodes_title * ' '
  end

  # 根节点
  def root
    @m_doc.at_xpath("/Nodes/N")
  end

  # 根节点的标题
  def root_title
    return "" if root.blank?
    _trans_xml_title(root["t"])
  end

  # 除根节点外的节点
  def child_nodes
    (nodes - [root])
  end

  # 除根节点外的节点
  def child_nodes_title
    child_nodes.map do |node|
      _trans_xml_title(node["t"])
    end
  end

  # 将XML的Attribute t中的字符串转义符全部转义，这个方法的写法比较有技巧性
  # ruby里gsub的强大用法之一
  def _trans_xml_title(title)
    title.gsub(/\\./){|m| eval '"'+m+'"'}
  end

  # 根节点的默认标题
  def root_default_title
    _trans_xml_title(@mindmap.title)
  end

  # 新建导图后的默认结构
  def save_on_default
    @mindmap.struct='<Nodes maxid="1"><N id="0" t="'+root_default_title+'" f="0"></N></Nodes>'
    @mindmap.save
  end

  # 解析XML并转换为Hash对象
  # 关于title
  # 数据库中XML上Attribute t中存储的字符串并非原本的显示字符串
  # 而是JSON字符串
  # 取出时需要利用trans_xml_title函数才能得到需要的真实字符串
  # 这么做的目的是为了在支持换行的同时避免歧义，同时又不违反XML的格式规则

  # 6月7日，Nodes的 x y 属性均作废
  # 8月24日 修改递归过程，防止产生过多的SQL
  def struct_hash
    @node_note_hash= @mindmap.node_notes

    doc = Nokogiri::XML @mindmap.struct
    nodes=doc.at_xpath("/Nodes")
    root=doc.at_xpath("/Nodes/N")
    shash={
      :id=>root['id'],
      :children=>struct_hash_recursion(root),
      :title=>_trans_xml_title(root['t']),
      :maxid=>nodes['maxid'],
      :revision=>nodes['revision'].to_i || 0,
      :image=>{
        :url=>root['i'],
        :height=>root['ih'],
        :width=>root['iw'],
        :border=>root['ib']
      },
      :note=>get_note_from(root['id'])
    }
    shash
  end

  def struct_hash_recursion(node)
    re=[]
    node.xpath('./N').each do |n|
      hn={
        :id=>n['id'],
        :title=>_trans_xml_title(n['t']),
        :fold=>n['f'],
        :putright=>n['pr'],
        :children=>struct_hash_recursion(n),
        :image=>{
          :url=>n['i'],
          :width=>n['iw'],
          :height=>n['ih'],
          :border=>n['ib']
        },
        :note=>get_note_from(n['id'])
      }
      re<<hn
    end
    re
  end

  def get_note_from(id)
    @node_note_hash[id] || ""
  end

  # 解析XML并转换为JSON字符串
  def struct_json
    struct_hash.to_json
  end

  # 重新生成 所有节点的id
  def refresh_local_id
    nodes.each do |cn|
      cn['id'] = randstr(8)
    end
    @mindmap.update_attribute(:struct,struct)
  end

  def revision
    @m_doc.at_css("Nodes")["revision"].to_i || 0
  end

end