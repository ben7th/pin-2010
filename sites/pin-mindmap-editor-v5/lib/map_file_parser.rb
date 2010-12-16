require 'uuidtools'
require 'xml/xslt'
require "rexml/document"
require 'rbconfig'
require 'base64'

class MapFileParser

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
  
end
