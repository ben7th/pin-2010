class MindmanagerParser < MapFileParser

  # 导入mindmanager格式的导图文件
  def self.import(mindmap,file_form_param)
    
    unzip_dir = "#{Dir::tmpdir}/mindmap_uploadtemp/#{UUIDTools::UUID.random_create.to_s}"

    path="#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}"
    File.open(path,"wb") do |file|
      file.write(file_form_param.read)
    end

    File.open(path,"r") do |file|
      Zip::ZipFile::open(file.path) {|zf|
        zf.each {|e|
          fpath = File.join(unzip_dir, e.name)
          FileUtils.mkdir_p(File.dirname(fpath))
          zf.extract(e,fpath)
        }
      }
    end

    mindmap.struct = xslt_transform("#{unzip_dir}/Document.xml","#{RAILS_ROOT}/public/xslt/mindmanager_to_mindpin.xslt")

    File.delete(path)
    FileUtils.rmtree(unzip_dir)

    mindmap.save
  end

  # 导出mindmanager格式的导图文件
  def self.export(mindmap)
    # 存放Document.xml文件的路径
    path="#{Dir::tmpdir}/#{UUIDTools::UUID.random_create.to_s}/"
    FileUtils.mkdir(path)
    file_name = "#{path}Document.xml"
    # 创建并解析document.xml,返回附件图片的文件路径
    image_files = create_and_parse_document(mindmap,file_name)
    # zip打包，并且将zip文件改名为mmap
    zip_dir = pack_to_zip(mindmap,file_name,image_files)
    File.delete(file_name)
    FileUtils.rm_r(path)
    return zip_dir
  end

  # 创建并解析document.xml
  def self.create_and_parse_document(mindmap,file_name)
    File.open(file_name,"wb") do |file|
      file.write(mindmap.struct)
    end
    # 读取xslt解析的xml内容
    mmap_xml = xslt_transform("#{file_name}","#{RAILS_ROOT}/public/xslt/mindpin_to_mindmanager.xslt")
    xml_content = Nokogiri::XML(mmap_xml)
    # 根据node的id得到node的备注，然后添加到document.xml中
    add_remarks_to_element(mindmap,xml_content)
    # node节点中的图片添加到document.xml中
    image_files = add_imgs_to_element(xml_content)
    # 用Nokogiri解析xml文件，将xml文件中的OId全部换成独立的
    xml_content.css('[OId]').each do |element|
      bytes = UUIDTools::UUID.random_create.raw
      element.attribute('OId').value = Base64.encode64(bytes).gsub("\n","")
    end
    # 将节点标题中的\\n都转化成\n
    xml_content.css('[PlainText]').each do |element|
      element.attribute("PlainText").value = element.attribute("PlainText").value.gsub(/\\./){|m| eval '"'+m+'"'}
    end
    # 将解析后正确的xml文件写入Document.xml中
    File.open(file_name,"w") do |file|
      file.write(xml_content.to_s.gsub("<ap:SubTopics/>",""))
    end
    return image_files
  end

  # 查找element中图片，下载后并添加到mmap的bin文件夹下，并保存在document.xml中
  # 并且设置图片的宽度和高度（暂时将原先大小的值除以4）
  def self.add_imgs_to_element(xml_content)
    image_files = []
    xml_content.css('ap|Image').each do |image_node|
      img_src_node = image_node.css('ap|ImageData cor|Uri')[0]
      image_url = img_src_node.inner_html
      response_body = HandleGetRequest.get_response_from_url(image_url)
      image_file_name = "#{UUIDTools::UUID.random_create.to_s.upcase}.bin"
      image_file_path = "#{Dir::tmpdir}/#{image_file_name}"
      file = File.open(image_file_path,"wb")
      file.write(response_body)
      file.close
      image_files << image_file_path
      img_src_node.inner_html = "mmarch://bin/#{image_file_name}"
      width = image_node.css('ap|ImageSize')[0].attribute("Width")
      width.value = ((width.value.to_i)/4.0).to_s
      height = image_node.css('ap|ImageSize')[0].attribute("Height")
      height.value = ((height.value.to_i)/4.0).to_s
    end
    image_files
  end

  # 查找element的所对应的备注，并添加到document.xml中去
  def self.add_remarks_to_element(mindmap,xml_content)
    mindmap.nodes.each do |node|
      xml_content.css("[OId='#{node.local_id}']").each do |n|
        notes_group = Nokogiri::XML::Node.new('NotesGroup',xml_content)
        notes_xhtml_data = Nokogiri::XML::Node.new('NotesXhtmlData',xml_content)
        notes_xhtml_data['Dirty'] = "0000000000000001"
        notes_xhtml_data['PreviewPlainText'] = node.note
        html_node = Nokogiri::XML::Node.new('html',xml_content)
        html_node['xmlns'] = "http://www.w3.org/1999/xhtml"
        html_node.inner_html = node.note
        html_node.default_namespace=("http://www.w3.org/1999/xhtml")
        notes_xhtml_data.add_child(html_node)
        notes_group.add_child(notes_xhtml_data)
        n.add_child(notes_group)
      end
    end
  end
  
  # 将需要的东西打包到mmap文件中
  def self.pack_to_zip(mindmap,file_name,image_files)
    zip_dir = "#{Dir::tmpdir}/#{mindmap.title}.mmap"
    FileUtils.rm(zip_dir) if File.exist?(zip_dir)
    Zip::ZipFile.open zip_dir, Zip::ZipFile::CREATE do |zip|
      zip.add("Document.xml", file_name)
      zip.add("bin", "#{RAILS_ROOT}/public/mmap_src_file/bin")
      zip.add("bin/B7E49899-8FA5-4C17-801C-3A2E2A90CF7B.bin", "#{RAILS_ROOT}/public/mmap_src_file/bin/B7E49899-8FA5-4C17-801C-3A2E2A90CF7B.bin")
      zip.add("xsd", "#{RAILS_ROOT}/public/mmap_src_file/xsd")
      zip.add("xsd/MindManagerApplication.xsd", "#{RAILS_ROOT}/public/mmap_src_file/xsd/MindManagerApplication.xsd")
      zip.add("xsd/MindManagerCore.xsd", "#{RAILS_ROOT}/public/mmap_src_file/xsd/MindManagerCore.xsd")
      zip.add("xsd/MindManagerDelta.xsd", "#{RAILS_ROOT}/public/mmap_src_file/xsd/MindManagerDelta.xsd")
      zip.add("xsd/MindManagerPrimitive.xsd", "#{RAILS_ROOT}/public/mmap_src_file/xsd/MindManagerPrimitive.xsd")
      image_files.each do |image_file|
        zip.add("bin/#{image_file.gsub("#{Dir::tmpdir}/","")}", image_file)
      end
    end
    # 删除临时文件
    image_files.each do |image_file|
      FileUtils.rm(image_file)
    end
    return zip_dir
  end
  
end
