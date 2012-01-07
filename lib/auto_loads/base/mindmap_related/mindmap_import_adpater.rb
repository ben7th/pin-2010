class MindmapImportAdpater
  class UnSupportFormatError<StandardError; end
  class StructError<StandardError; end
  class CreateThumbError<StandardError; end
    
  TEMP_FILE_BASE_DIR = '/web/2010/daotu_files/mindmap_import_tempfile'
  
  attr_reader :file_type, :nodes_count, :title, :thumb_src
  def initialize(user)
    @user = user
    user_id_str = @user.id.to_s
    
    @temp_file_dir    = File.join(TEMP_FILE_BASE_DIR, user_id_str)
    @thumb_file_path  = File.join(@temp_file_dir, 'thumb')      # 缩略图
    @struct_file_path = File.join(@temp_file_dir, 'struct.xml') # 结构信息
    
    @thumb_src   = pin_url_for('dtimg',"mindmap_import_tempfile/#{user_id_str}/thumb")
  end
  
  # 尝试从上传的文件中解析导图
  # 接收的参数类型应为 ActionDispatch::Http::UploadedFile
  # 参考：http://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html
  def import(uploaded_file)    
    _build_attributes(uploaded_file)
    _create_temp_file(uploaded_file)
  end
  
#  def original_file_path
#    Dir[File.join(@temp_file_dir,"original*")].pop
#  end
  
#  def find_last_import
#    @raw_file = File.new(@original_file_path,"r")
#    @file_name = File.basename(@original_file_path)
#    @original_file_path = original_file_path
#    _build_attributes
#  end
  
  
#  def remove_temp_file
#    FileUtils.rm_rf(@temp_file_dir)
#  end
  
#  def imported?
#    !@raw_file.blank?
#  end
  
  private
    def _build_attributes(uploaded_file)
      file_name = uploaded_file.original_filename
      
      @title   = File.basename(file_name, ".*")
      ext_name = File.extname(file_name)
      
      Rails.logger.debug('解析上传导图文件')
      Rails.logger.debug("文件名: #{file_name}")
      Rails.logger.debug("扩展名: #{ext_name}")
      
      case ext_name
        when '.mmap'
          @struct = MindmanagerParser.struct_of_import(uploaded_file)
          @file_type = 'Mindmanager'
        when '.mm'
          @struct = FreemindParser.struct_of_import(uploaded_file)
          @file_type = 'Freemind'
        when '.xmind'
          @struct = XmindParser.struct_of_import(uploaded_file)
          @file_type = 'Xmind'
        else
          raise UnSupportFormatError, '不支持这种导图格式'
      end
      
      @nodes_count = Nokogiri::XML(@struct).css("node").count
    rescue UnSupportFormatError => ex
      raise ex
    rescue Exception
      raise StructError, '导图文件解析失败'
    end
  
    def _create_temp_file(uploaded_file)
      original_file_path = File.join(@temp_file_dir, 'original')
      
      # 保存原始文件 original.xxx
      FileUtils.mkdir_p(@temp_file_dir)
      FileUtils.cp(uploaded_file.path, original_file_path)
      
      # 生成 struct.xml
      File.open(@struct_file_path, 'w') do |f|
        f << @struct
      end
      
      # 生成 thumb.png
      mindmap = Mindmap.new(:struct=>@struct)
      
      begin
        tmp_image_path = MindmapToImage.new(mindmap).export("120x120")
      rescue Exception
        raise CreateThumbError,"生成导图缩略图出错"
      end
      
      FileUtils.cp(tmp_image_path, @thumb_file_path)
    end
  
end
