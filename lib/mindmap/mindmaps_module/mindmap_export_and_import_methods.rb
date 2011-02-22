module MindmapExportAndImportMethods
  # 将网站中的思维导图，保存为mindmanager格式
  def export_to_mindmanager
    MindmanagerParser.export(self)
  end

  # 将网站中的思维导图，保存为xmind格式
  def export_to_xmind
    XmindParser.export(self)
  end

  # 从表单上传的文件导入思维导图
  def import_from_file_and_save(file)
    type = file.original_filename.split(".").last
    case type
    when 'mmap' then MindmanagerParser.import(self,file)
    when 'mm' then FreemindParser.import(self,file)
    when 'xmind' then XmindParser.import(self,file)
    when 'imm' then ImindmapParser.import(self,file)
    end
  end
end