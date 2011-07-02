class ImindmapParser < MapFileParser
  def self.import(mindmap,file_form_param)
    mindmap.struct = self.struct_of_import(file_form_param)
    mindmap.save
  end

  def self.struct_of_import(file_form_param)
    imm_xml = self._find_xml_from_imm(file_form_param)
    struct = xslt_transform_form_xml(imm_xml,MapFileParser.xslt_file_path("imindmap_import.xslt"))
    process_note_id_to_randstr(struct)
  end

  # 从 imm 文件中找出 xml
  def self._find_xml_from_imm(file_form_param)
    Zip::ZipFile::open(file_form_param.path) do |zf|
      zf.each do |f|
        if f.name =~ /.*\.mmd$/
          return f.get_input_stream{|is|is.read}
        end
      end
    end
  end

  def self.export(mindmap)
    mmd_xml = self._produce_mmd_xml(mindmap)
    self._pack_xml_and_png_to_zip(mmd_xml)
  end

  def self._pack_xml_and_png_to_zip(mmd_xml)
    struct_file_path = self._produce_temp_file(mmd_xml)
    root_img_file_path = self.imm_src_file_path("ellipse.png")

    zip_dir = "#{Dir::tmpdir}/imm_#{randstr}"
    Zip::ZipFile.open zip_dir, Zip::ZipFile::CREATE do |zip|
      zip.add("struct.mmd",struct_file_path)
      zip.add("ellipse.png",root_img_file_path)
    end

    FileUtils.remove(struct_file_path)
    return File.read(zip_dir)
  end

  # 根据 mindmap 生成 imm 文件包中的 mmd 文件里的 xml 内容
  def self._produce_mmd_xml(mindmap)
    xsltpath = MapFileParser.xslt_file_path("imindmap_export.xslt")
    xml = self.xslt_transform_form_xml(mindmap.struct,xsltpath)
    nokogiri_doc = Nokogiri::XML(xml)
    self._handle_node_title(nokogiri_doc)
    self._handle_note(mindmap,nokogiri_doc)

    return nokogiri_doc.to_s
  end

  # 处理 标题中的换行
  def self._handle_node_title(nokogiri_doc)
    nokogiri_doc.css("branch").each do |branch|
      branch["name"] = branch["name"].gsub(/\\n/,"    ")
    end
  end

  # 处理 备注
  def self._handle_note(mindmap,nokogiri_doc)
     mindmap.nodes.each do |node|
      nokogiri_doc.css("##{node.local_id}").each do |branch|
        branch["text"] = node.note
      end
    end
  end

  # 把 str 放入一个临时文件
  def self._produce_temp_file(str,pre="temp")
    path="#{Dir::tmpdir}/#{pre}_#{randstr}"
    File.open(path,"wb") do |file|
      file.write(str)
    end
    path
  end

  def self.imm_src_file_path(path)
    File.join(self.depend_file_path,"imm_src_file",path)
  end
end