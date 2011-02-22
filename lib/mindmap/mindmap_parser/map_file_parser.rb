require 'uuidtools'
require 'xml/xslt'
require "rexml/document"
require 'rbconfig'
require 'base64'

class MapFileParser

  # 用 xslt 导入的导图节点 id 是 序列数字
  # 把这些序列数字传化成 randstr(20)
  def self.process_note_id_to_randstr(struct)
    doc = Nokogiri::XML(struct)
    doc.css("node").each{|n|n["id"]=randstr(20)}
    doc.to_s
  end

  def self.xslt_transform_form_xml(sourcexml,xsltpath)
    self._xslt_transform(sourcexml,File.read(xsltpath))
  end

  def self.xslt_transform_form_filepath(sourcepath,xsltpath)
    self._xslt_transform(File.read(sourcepath),File.read(xsltpath))
  end

  def self._xslt_transform(xml_str,xslt_str)
    xslt = XML::XSLT.new()
    xslt.xml = REXML::Document.new xml_str
    xslt.xsl = REXML::Document.new xslt_str
    out=xslt.serve()
    system_os = Config::CONFIG['host_os']
    if system_os=="mswin32"
      out.to_s
    elsif system_os=="linux-gnu"
      out.to_s.gsub(/&amp;/,'&')
    else
      out.to_s
    end
  end

  def self.xslt_transform(sourcepath,xsltpath)
    self.xslt_transform_form_filepath(sourcepath,xsltpath)
  end

  def self.xslt_file_path(file_name)
    File.join(self.depend_file_path,"xslt/#{file_name}")
  end

  def self.depend_file_path
    "#{RAILS_ROOT}/../../lib/mindmap/mindmap_parser/"
  end
  
end
