class MindmapImporter
  class UnSupportFormatError < StandardError; end
  class StructError < StandardError; end
  
  attr_reader :title, :struct
  
  def self.load(uploaded_file)
    impoter = self.new
    impoter._build(uploaded_file)
    return impoter
  end

  def _build(uploaded_file)
    file_name = uploaded_file.original_filename
    
    @title   = File.basename(file_name, ".*")
    ext_name = File.extname(file_name)
    
    case ext_name
      when '.mmap'
        @struct = MindmanagerParser.struct_of_import(uploaded_file)
      when '.mm'
        @struct = FreemindParser.struct_of_import(uploaded_file)
      when '.xmind'
        @struct = XmindParser.struct_of_import(uploaded_file)
      else
        raise UnSupportFormatError, '不支持这样的文件格式'
    end
    
  rescue UnSupportFormatError => ex
    raise ex
  rescue Exception
    raise StructError, '文件解析失败'
  end
  
end
