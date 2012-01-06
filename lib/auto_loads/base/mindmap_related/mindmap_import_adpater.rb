class MindmapImportAdpater
  class UnSupportFormatError<StandardError;end
  class StructError<StandardError;end
  class CreateThumbError<StandardError;end
  if Rails.env.development?
    TEMP_FILE_BASE_DIR = "/web1/2010/upload_mindmap_tempfile"
  else
    TEMP_FILE_BASE_DIR = "/web/2010/upload_mindmap_tempfile"
  end
  
  attr_reader :file_type,:nodes_count,:title
  def initialize(user)
    @user = user
    user_id_str = @user.id.to_s
    @temp_file_dir  = File.join(TEMP_FILE_BASE_DIR, user_id_str)
    @thumb_file_path = File.join(@temp_file_dir, 'thumb_tmp')
    @struct_file_path = File.join(@temp_file_dir, "struct.xml")
    @thumb_file_url  = pin_url_for("ui","upload_mindmap_tempfile/#{user_id_str}/thumb_tmp")
  end
  
  def original_file_path
    Dir[File.join(@temp_file_dir,"original*")].pop
  end
  
  def find_last_import
    @raw_file = File.new(@original_file_path,"r")
    @file_name = File.basename(@original_file_path)
    @original_file_path = original_file_path
    build_attributes
  end
  
  def import(raw_file,file_name)
    @raw_file = raw_file
    @file_name = file_name
    @original_file_path = File.join(@temp_file_dir, "original#{File.extname(file_name)}")
    build_attributes
    create_temp_file
  end
  
  def remove_temp_file
    FileUtils.rm_rf(@temp_file_dir)
  end
  
  def create_temp_file
    # 保存原始文件 original.xxx
    FileUtils.cp(@raw_file.path,@original_file_path)
    
    # 生成 struct.xml
    File.open(@struct_file_path,"w") do |f|
      f << @struct
    end
    
    # 生成 thumb.png
    mindmap = Mindmap.new(:struct=>struct)
    begin
      tmp_image_path = MindmapToImage.new(mindmap).export("120x120")
    rescue Exception => ex
      raise CreateThumbError,"生成导图缩略图出错"
    end
    FileUtils.cp(tmp_image_path,@thumb_file_path)
    
    #    File.chmod(0666, @thumb_file_path)
    
    return self
  end
  
  def imported?
    !@raw_file.blank?
  end
  
  private
  def build_attributes
    build_struct_of_raw_file
    build_file_type
    build_nodes_count
    build_title
  end
  
  def build_struct_of_raw_file
    name_splits = @file_name.split(".")
    type = name_splits.pop
    
    struct = case type
      when 'mmap' then MindmanagerParser.struct_of_import(@raw_file)
      when 'mm' then FreemindParser.struct_of_import(@raw_file)
      when 'xmind' then XmindParser.struct_of_import(@raw_file)
      when 'imm' then ImindmapParser.struct_of_import(@raw_file)
    else
      raise UnSupportFormatError,"不支持的导图格式"
    end
    
    @struct = struct
  rescue Exception => ex
    if ex.class == UnSupportFormatError
      raise ex
    else
      raise StructError,"解析导图结构出现错误"
    end
  end
  
  def build_file_type
    name_splits = @file_name.split(".")
    type = name_splits.pop
    
    str = case type
      when 'mmap'  then "Mindmanager"
      when 'mm'    then "Freemind"
      when 'xmind' then "Xmind"
      when 'imm'   then "Imindmap"
    else
      raise UnSupportFormatError,"不支持的导图格式"
    end
    @file_type = str
  end
  
  def build_nodes_count
    @nodes_count = Nokogiri::XML(@struct).css("node").count
  end
  
  def build_title
    name_splits = @file_name.split(".")
    name_splits.first
  end
end
