class FreemindParser < MapFileParser
  # 导入Freemind格式的导图文件
  def self.import(mindmap,file_form_param)
    struct = xslt_transform_form_xml(file_form_param,"#{RAILS_ROOT}/public/xslt/freemind_to_mindpin.xslt")
    struct = process_note_id_to_randstr(struct)
    mindmap.struct = struct
    mindmap.save
  end

  def self.export(mindmap,v="9")
    return self.export_v8(mindmap) if v == "8"
    self.export_v9(mindmap)
  end

  def self.export_v8(mindmap)
    xsltpath = "#{RAILS_ROOT}/public/xslt/mindpin_to_freemind_8.xslt"
    xml = self.xslt_transform_form_xml(mindmap.struct,xsltpath)
    nokogiri_doc = Nokogiri::XML(xml)

    self._v8_handle_node_title(nokogiri_doc)
    self._v8_handle_note(mindmap,nokogiri_doc)

    return nokogiri_doc.to_s
  end

  # 处理节点标题中的换行
  def self._v8_handle_node_title(nokogiri_doc)
    nokogiri_doc.css("node").each do |n|
      n["TEXT"] = n["TEXT"].gsub(/\\./){|m| eval '"'+m+'"'}
    end
  end

  # 处理 备注
  def self._v8_handle_note(mindmap,nokogiri_doc)

    node_note_hash = mindmap.node_notes

    mindmap.struct_obj.nodes.each do |node|

      node_id = node['id']
      note = node_note_hash[node_id]

      nokogiri_doc.css("##{node_id}").each do |n|
        new_node = Nokogiri::XML::Node.new('hook',nokogiri_doc)
        new_node["name"] = "accessories/plugins/NodeNote.properties"
        text = Nokogiri::XML::Node.new('text',nokogiri_doc)
        text.content = "#{note.replace_html_enter_tags_to_text}"
        new_node.add_child(text)
        n.add_child(new_node)
      end
    end
  end

  def self.export_v9(mindmap)
    xsltpath = "#{RAILS_ROOT}/public/xslt/mindpin_to_freemind_9.xslt"
    xml = self.xslt_transform_form_xml(mindmap.struct,xsltpath)
    nokogiri_doc = Nokogiri::XML(xml)

    self._v9_handle_node_title(nokogiri_doc)
    self._v9_handle_note(mindmap,nokogiri_doc)

    return nokogiri_doc.to_s
  end

  # 处理节点标题
  def self._v9_handle_node_title(nokogiri_doc)
    nokogiri_doc.css("node richcontent[TYPE='NODE'] html body div").each do |n|
      str = n.inner_html
      str.gsub!(/\\n/,"<br>")
      n.inner_html = str
    end
  end

  # 处理 备注
  def self._v9_handle_note(mindmap,nokogiri_doc)

    node_note_hash = mindmap.node_notes

    mindmap.struct_obj.nodes.each do |node|

      node_id = node['id']
      note = node_note_hash[node_id]

      nokogiri_doc.css("##{node_id}").each do |n|

        richcontent = Nokogiri::XML::Node.new('richcontent',nokogiri_doc)
        richcontent["TYPE"] = "NOTE"

        richcontent.inner_html = %`
              <html>
                <head>
                </head>
                <body>
                  #{note}
                </body>
              </html>
        `
        n.add_child(richcontent)
      end
    end
  end
  
end