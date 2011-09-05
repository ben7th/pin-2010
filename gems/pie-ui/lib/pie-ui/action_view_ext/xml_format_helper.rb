module PieUi
  module XmlFormatHelper
    # 自动格式化xml字符串，增加换行和缩进。
    # 由于汉字等字符会被Nokogiri转码，不得已采取了解析两次的方法
    # 以后有好的方法再说吧
    def autoformat_xml(xmlstr)
      Nokogiri::HTML.fragment(Nokogiri::XML.fragment(xmlstr).to_xml).to_html
    end
  end
end
