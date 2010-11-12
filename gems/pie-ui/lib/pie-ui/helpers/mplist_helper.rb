module PieUi
  module MplistHelper
    def mplist(collection=[], options={}, &block)
      config = PieUi::MplistHelperConfig.new(@template,collection,options)
      concat config.ul_html(&block)
    end
  end
end