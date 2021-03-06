class WordXmlParser < MapFileParser
  
  XSLT_PATH = xslt_file_path("mindpin_to_outline_doc.xslt")

  def self.export(mindmap)
    xmind_content = xslt_transform_form_xml(mindmap.struct, XSLT_PATH)

    out_xml = Nokogiri::XML(xmind_content)
    out_xml.css('w|t').each do |element|
      element.inner_html = element.inner_html.gsub("\\n"," ")
    end
    
    # 处理mindmap的节点的备注信息
    add_note_to_outline(mindmap, out_xml)

    file_path = "#{Dir::tmpdir}/mindmap_outline_#{UUIDTools::UUID.random_create.to_s}.doc"
    doc_file = File.open(file_path,"w+")
    doc_file.write(out_xml.to_s)
    doc_file.close
    return file_path
  end

  # 找到out_xml中有note的节点，添加为这个节点增加内容，
  # 然后删除所有的临时生成的note（为了便于找到有note的节点）标签
  def self.add_note_to_outline(mindmap,out_xml)

    mindmap.node_notes.each {|node_id, note|
      out_xml.css("note[id='#{node_id}']").each {|n|
        wp = Nokogiri::XML::Node.new('w:p', out_xml)
        wp.default_namespace=("http://schemas.microsoft.com/office/word/2003/wordml")

        reduce_string_br(note).split("\n").each{|text|
          wr = Nokogiri::XML::Node.new('w:r', wp)
          wt = Nokogiri::XML::Node.new('w:t', wp)
          wt.inner_html = text
          wbr = Nokogiri::XML::Node.new('w:br', wp)

          wr.add_child(wt)
          wr.add_child(wbr)

          wp.add_child(wr)
        }

        n.parent.add_child(wp)
      }
    }

    # 移除所有备注标记临时节点
    out_xml.css("note").remove
  end

end
#Nokogiri::XSLT.parse(File.open(@xslt)).transform(Nokogiri::XML.parse(File.open(@xml)))