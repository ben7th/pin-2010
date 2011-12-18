class MindmapImportAdpater
  class UnSupportFormatError<StandardError;end
  class StructError<StandardError;end
  class CreateThumbError<StandardError;end

  if RAILS_ENV == "development"
    ATTACHED_FILE_PATH_ROOT = "/web1/2010/cache_images"
  else
    ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"
  end

  def self.remove_file_by_upload_temp_id(upload_temp_id)
    FileUtils.rm_rf(self.dir_path(upload_temp_id))
  end

  def self.nodes_count_by_upload_temp_id(upload_temp_id)
    struct = self.struct_by_upload_temp_id(upload_temp_id)
    Nokogiri::XML(struct).css("node").count
  end

  def self.title_by_filename(filename)
    name_splits = filename.split(".")
    name_splits.first
  end

  def self.file_type_by_filename(filename)
    name_splits = filename.split(".")
    type = name_splits.pop

    str = case type
    when 'mmap'  then "Mindmanager"
    when 'mm'    then "Freemind"
    when 'xmind' then "Xmind"
    when 'imm'   then "Imindmap"
    else
      raise UnSupportFormatError,"不支持的导图格式"
    end
    str
  end

  def self.original_file_path_by_upload_temp_id(upload_temp_id)
      self.original_file_path(upload_temp_id)
  end

  def self.thumb_file_path_by_upload_temp_id(upload_temp_id)
    self.thumb_file_path(upload_temp_id)
  end

  def self.thumb_url_by_upload_temp_id(upload_temp_id)
    pin_url_for("pin-daotu","/mindmaps/import_file_thumb/#{upload_temp_id}/thumb.png")
  end

  def self.struct_by_upload_temp_id(upload_temp_id)
    File.new(self.struct_file_path(upload_temp_id)).read
  end

  # 返回 randstr
  def self.create_by_upload_file(file,file_name)
    upload_temp_id = randstr

    dir_path = self.dir_path(upload_temp_id)
    FileUtils.mkdir_p(dir_path)

    # 保存原始文件 original.xxx
    dir_path = self.dir_path(upload_temp_id)
    original_file_path = File.join(dir_path,"original#{File.extname(file_name)}")
    FileUtils.cp(file.path,original_file_path)

    # 生成 struct.xml
    struct_file_path = self.struct_file_path(upload_temp_id)
    struct = self.struct_of_upload_file(file,file_name)
    File.open(struct_file_path,"w") do |f|
      f << struct
    end

    # 生成 thumb.png
    thumb_file_path = self.thumb_file_path(upload_temp_id)
    mindmap = Mindmap.new(:struct=>struct)
    begin
      tmp_image_path = MindmapToImage.new(mindmap).export("120x120")
    rescue Exception => ex
      raise CreateThumbError,"生成导图缩略图出错"
    end
    FileUtils.cp(tmp_image_path,thumb_file_path)

    upload_temp_id
  end

  private
  def self.struct_of_upload_file(file,file_name)
    name_splits = file_name.split(".")
    type = name_splits.pop

    struct = case type
    when 'mmap' then MindmanagerParser.struct_of_import(file)
    when 'mm' then FreemindParser.struct_of_import(file)
    when 'xmind' then XmindParser.struct_of_import(file)
    when 'imm' then ImindmapParser.struct_of_import(file)
    else
      raise UnSupportFormatError,"不支持的导图格式"
    end
    
    struct
  rescue Exception => ex
    if ex.class == UnSupportFormatError
      raise ex
    else
      raise StructError,"解析导图结构出现错误"
    end
  end

  def self.dir_path(upload_temp_id)
    File.join(ATTACHED_FILE_PATH_ROOT,"upload_import_mindmap_files/#{upload_temp_id}")
  end

  def self.struct_file_path(upload_temp_id)
    dir_path = self.dir_path(upload_temp_id)
    File.join(dir_path,"struct.xml")
  end

  def self.thumb_file_path(upload_temp_id)
    dir_path = self.dir_path(upload_temp_id)
    File.join(dir_path,"thumb.png")
  end

  def self.original_file_path(upload_temp_id)
    dir_path = self.dir_path(upload_temp_id)
    Dir[File.join(dir_path,"original*")].pop
  end
end
