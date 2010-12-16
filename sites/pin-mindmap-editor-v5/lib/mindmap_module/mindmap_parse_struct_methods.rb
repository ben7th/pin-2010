module MindmapParseStructMethods
  # 解析XML并转换为Hash对象
  # 关于title
  # 数据库中XML上Attribute t中存储的字符串并非原本的显示字符串
  # 而是JSON字符串
  # 取出时需要利用trans_xml_title函数才能得到需要的真实字符串
  # 这么做的目的是为了在支持换行的同时避免歧义，同时又不违反XML的格式规则

  # 6月7日，Nodes的 x y 属性均作废
  # 8月24日 修改递归过程，防止产生过多的SQL
  def struct_hash
    @node_note_hash=Hash.new('')
    self.nodes.each do |n|
      @node_note_hash[n.local_id]=n.note unless n.note.blank?
    end
    doc = Nokogiri::XML self.struct
    nodes=doc.at_xpath("/Nodes")
    root=doc.at_xpath("/Nodes/N")
    shash={
      :id=>root['id'],
      :children=>struct_hash_recursion(root),
      :title=>trans_xml_title(root['t']),
      :maxid=>nodes['maxid'],
      :image=>{
        :url=>nodes['i'],
        :height=>nodes['ih'],
        :width=>nodes['iw'],
        :border=>nodes['ib']
      },
      :note=>self.get_note_from(root['id'])
    }
    shash
  end

  def struct_hash_recursion(node)
    re=[]
    node.xpath('./N').each do |n|
      hn={
        :id=>n['id'],
        :title=>trans_xml_title(n['t']),
        :fold=>n['f'],
        :putright=>n['pr'],
        :children=>struct_hash_recursion(n),
        :image=>{
          :url=>n['i'],
          :width=>n['iw'],
          :height=>n['ih'],
          :border=>n['ib']
        },
        :note=>self.get_note_from(n['id'])
      }
      re<<hn
    end
    re
  end

  def get_note_from(id)
    @node_note_hash[id]
  end

  # 解析XML并转换为JSON字符串
  def struct_json
    self.struct_hash.to_json
  end
end