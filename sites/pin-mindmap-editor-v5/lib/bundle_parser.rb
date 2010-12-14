class BundleParser < MapFileParser

  def initialize(text)
    @bundle_text = Nokogiri::XML(text).at_css("bundle").to_s
  end

  def has_bundle_text?
    !@bundle_text.blank?
  end

  # 把 bundle 格式的xml 转换成导图 struct
  def parse
    self.class.xslt_transform_form_xml(@bundle_text,"#{RAILS_ROOT}/public/xslt/bundle_to_mindpin.xslt")
  end

end
