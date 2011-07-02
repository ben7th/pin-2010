class MindmapImportAdpater
  ATTACHED_FILE_PATH_ROOT = "/web/2010/cache_images"

  def self.thumb_by_randstr_id(randstr_id)
    self.thumb_file_path(randstr_id)
  end

  def self.struct_by_randstr_id(randstr_id)
    File.new(self.struct_file_path(randstr_id)).read
  end

  # 返回 randstr
  def self.create_by_upload_file(file,file_name)
    randstr_id = randstr

    dir_path = self.dir_path(randstr_id)
    FileUtils.mkdir_p(dir_path)

    # 生成 struct.xml
    struct_file_path = self.struct_file_path(randstr_id)
    struct = self.class.struct_of_upload_file(file,file_name)
    File.open(struct_file_path,"w") do |f|
      f << struct
    end

    # 生成 thumb.png
    thumb_file_path = self.thumb_file_path(randstr_id)
    mindmap = Mindmap.new(:struct=>struct)
    begin
      tmp_image_path = MindmapToImage.new(mindmap).export("120x120")
    rescue Exception => ex
      raise "生成缩略图失败"
    end
    FileUtils.cp(tmp_image_path,thumb_file_path)

    randstr_id
  end

  private
  def self.struct_of_upload_file(file,file_name)
    name_splits = file_name.split(".")
    type = name_splits.pop

    struct = case type
    when 'mmap' then MindmanagerParser.struct_of_import(mindmap,file)
    when 'mm' then FreemindParser.struct_of_import(mindmap,file)
    when 'xmind' then XmindParser.struct_of_import(mindmap,file)
    when 'imm' then ImindmapParser.struct_of_import(mindmap,file)
    else
      raise "错误的导图格式"
    end
    
    struct
  end

  def self.dir_path(randstr_id)
    File.join(ATTACHED_FILE_PATH_ROOT,"upload_import_mindmap_files/#{randstr_id}")
  end

  def self.struct_file_path(randstr_id)
    dir_path = self.dir_path(randstr_id)
    File.join(dir_path,"struct.xml")
  end

  def self.thumb_file_path(randstr_id)
    dir_path = self.dir_path(randstr_id)
    File.join(dir_path,"thumb.png")
  end
end
