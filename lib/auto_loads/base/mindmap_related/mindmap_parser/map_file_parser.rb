require 'uuidtools'
require 'xml/xslt'
require "rexml/document"
require 'base64'

class MapFileParser

# TODO 重构，把类方法变为实例方法，以简化代码调用
# 今年先算了，2012年有时间再做吧
#  def initialize(mindmap)
#    @mindmap  = mindmap
#    @document = mindmap.document
#  end
  
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
    xslt.serve().to_s.gsub(/&amp;/, '&')
  end

  def self.xslt_transform(sourcepath, xsltpath)
    self.xslt_transform_form_filepath(sourcepath, xsltpath)
  end

  def self.xslt_file_path(file_name)
    File.join(self.depend_file_path,"xslt/#{file_name}")
  end

  def self.depend_file_path
    File.dirname(File.expand_path(__FILE__))
  end

  def self.reduce_string_br(str)
    str1 = str.gsub(/<\/?[^>]*>/, '<br>')
    str1.gsub!(/(<\/?br>)+/, "\n")
    str1.gsub!(/^(\n)+/, '')
    str1.gsub!('&nbsp;', '')
    str1
  end
end
