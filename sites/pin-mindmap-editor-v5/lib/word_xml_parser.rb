class WordXmlParser < MapFileParser

  def self.import(mindmap,file_from_params)
  end

  def self.export(mindmap)
    xsltpath = "#{RAILS_ROOT}/public/xslt/mindpin_to_outline_doc.xslt"
    xmind_content = xslt_transform_form_xml(mindmap.struct,xsltpath)

    out_xml = Nokogiri::XML(xmind_content)
    out_xml.css('w|t').each do |element|
      element.inner_html = element.inner_html.gsub("\\n"," ")
    end
    # 处理mindmap的节点的备注信息
    add_note_to_outline(mindmap,out_xml)
    file_path = "#{Dir::tmpdir}/mindmap_outline_#{UUIDTools::UUID.random_create.to_s}.doc"
    doc_file = File.open(file_path,"w+")

    doc_file.write(out_xml.to_s)
    doc_file.close
    return file_path
  end

  # 找到out_xml中有note的节点，添加为这个节点增加内容，
  # 然后删除所有的临时生成的note（为了便于找到有note的节点）标签
  def self.add_note_to_outline(mindmap,out_xml)

    node_note_hash = mindmap.node_notes

    mindmap.struct_obj.nodes.each do |node|

      node_id = node['id']
      note = node_note_hash[node_id]

      out_xml.css("note[id='#{node_id}']").each do |n|
        str = ''
        note.replace_html_enter_tags_to_text.split("\n").each do |text|
          str << %`<w:r><w:rPr><w:rFonts w:cs="Arial"/><wx:font wx:val="宋体"/><w:sz w:val="20"/>
              <w:sz-cs w:val="20"/></w:rPr><w:t>#{text}</w:t><w:br/></w:r>`
        end
        w_p = Nokogiri::XML::Node.new('w:p',out_xml)
        w_p.inner_html = %`
          <w:pPr><w:spacing w:before="56" w:after="113"/><w:rPr><w:rFonts w:cs="Arial"/>
          <w:sz w:val="20"/><w:sz-cs w:val="20"/></w:rPr></w:pPr>#{str}
        `
        w_p.default_namespace=("http://schemas.microsoft.com/office/word/2003/wordml")
        n.parent.add_child(w_p)
      end
    end
    out_xml.css("note").each do |n_tmp|
      n_tmp.remove
    end
  end

end
#Nokogiri::XSLT.parse(File.open(@xslt)).transform(Nokogiri::XML.parse(File.open(@xml)))