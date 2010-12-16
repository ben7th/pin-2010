class XmindParser < MapFileParser

  # 导入
  def self.import(mindmap,file_from_params)
    xmind_xml = get_content_xml(file_from_params)
    # 将这个声明清空，否则无法转换
    xmind_xml.gsub!("urn:xmind:xmap:xmlns:content:2.0","")
    # 将content.xml 用xslt 转成 mindmap 的struct
    struct = xslt_transform_form_xml(xmind_xml,"#{RAILS_ROOT}/public/xslt/xmind_import.xslt")
    struct = process_note_id_to_randstr(struct)
    
    mindmap.struct = struct
    mindmap.save
  end

  # 得到xmind文件中的content.xml
  def self.get_content_xml(file_from_params)
    Zip::ZipFile::open(file_from_params.path) do |zf|
      zf.each do |f|
        if f.name == "content.xml"
          return f.get_input_stream{|is|is.read}
        end
      end
    end
  end

  # 导出
  def self.export(mindmap)
    xmind_content = xslt_transform_form_xml(mindmap.struct,"#{RAILS_ROOT}/public/xslt/xmind_export.xslt")
    xml_content = Nokogiri::XML(xmind_content)
    # manifest.xml 创建这个
    manifest_xml = Nokogiri::XML(%`<?xml version="1.0" encoding="UTF-8" standalone="no" ?> <manifest xmlns="urn:xmind:xmap:xmlns:manifest:1.0"></manifest>`)
    # 将mindmap的备注添加到xml中
    add_notes_to_xml(mindmap,xml_content)
    # 保存图片
    img_files = get_img_files(xml_content)
    # 修正标题中的双斜杠
    titles_to_single_sprit(xml_content)
    # 将xml保存到一个content.xml的文件中
    file_path = save_content_file(xml_content)
    # 创建这个类型的zip压缩文件，并把content.xml保存到这个压缩文件中去
    # 同时将文件信息保存在manifest.xml中
    put_file_to_zip(file_path,img_files,manifest_xml)
  end

  # 将转化后的xml保存到文件中
  def self.save_content_file(xmind_content)
    file_name = "#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}"
    File.open(file_name,"wb") do |file|
      file.write(xmind_content)
    end
    return file_name
  end

  # 将文件加入到zip文件夹中
  def self.put_file_to_zip(file,img_files,manifest_xml)
    zip_path = "#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}.xmind"
    FileUtils.rm(zip_path) if File.exist?(zip_path)
    manifest_xml_file = add_message_to_manifest_xml(manifest_xml,img_files)
    Zip::ZipFile.open zip_path, Zip::ZipFile::CREATE do |zip|
      zip.add("content.xml", file)
      img_files.each do |image_file|
        zip.add("attachments/#{image_file.gsub("#{Dir::tmpdir}/","")}", image_file)
      end
      zip.add("META-INF/manifest.xml", manifest_xml_file)
    end
    FileUtils.rm(img_files)
    FileUtils.rm(file)
    FileUtils.rm(manifest_xml_file)
    return zip_path
  end

  # 将添加的文件信息放到manifest.xml中
  def self.add_message_to_manifest_xml(manifest_xml,image_files)
    manifest = manifest_xml.at('manifest')
    image_files.each do |image_file|
      file_entry = Nokogiri::XML::Node.new('file-entry',manifest_xml)
      file_entry["full-path"] = "attachments/#{image_file.gsub("#{Dir::tmpdir}/","")}"
      file_entry["media-type"] = ""
      manifest.add_child(file_entry)
    end
    path = "#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}"
    file = File.open(path,"w+")
    file.write(manifest_xml.to_s)
    file.close
    return path
  end

  # 添加备注信息
  def self.add_notes_to_xml(mindmap,xml_content)
    mindmap.nodes.each do |node|
      xml_content.css("[id='#{node.local_id}']").each do |n|
        notes = Nokogiri::XML::Node.new('notes',xml_content)
        html = Nokogiri::XML::Node.new('html',xml_content)
        notes.default_namespace=("http://www.w3.org/1999/xhtml")
        node.note.split(/<br\/?>/).each do |text|
          xhtml_p = Nokogiri::XML::Node.new('xhtml:p',xml_content)
          xhtml_p.inner_html=text
          html.add_child(xhtml_p)
        end
        plain = Nokogiri::XML::Node.new('plain',xml_content)
        node_plain_xmind = node.note.split(/<br\/?>/).map{|text| text }*" "
        plain.inner_html = node_plain_xmind
        notes.add_child(html)
        notes.add_child(plain)
        n.add_child(notes)
      end
    end
  end

  # 把每一个节点中的\\n修正为\n
  def self.titles_to_single_sprit(xml_content)
    xml_content.css('title').each do |element|
      element.inner_html = element.inner_html.gsub(/\\./){|m| eval '"'+m+'"'}
    end
  end

  # 得到所有的图片
  def self.get_img_files(xml_content)
    img_files = []
    xml_content.css('xhtml|img').each do |img_element|
      img_src = img_element['src']
      img_file_name = "#{UUIDTools::UUID.random_create.to_s}"+".#{img_src.split(".")[-1]}"
      image_file_path = "#{Dir::tmpdir}/#{img_file_name}"
      file = File.open(image_file_path,"wb")
      file.write(HandleGetRequest.get_response_from_url(img_src))
      file.close
      img_element['xhtml:src'] = "xap:attachments/#{img_file_name}"
      img_files << image_file_path
    end
    img_files
  end

end
