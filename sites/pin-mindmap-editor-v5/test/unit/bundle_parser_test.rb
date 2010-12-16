require 'test_helper'

class BundleParserTest < ActiveSupport::TestCase
  test "bundle 转换成 mindmap" do
    xslt = "#{RAILS_ROOT}/public/xslt/bundle_to_mindpin.xslt"
    xml = %`
      <bundle>
        <text value="&lt;br&gt;第\\n一">
          <image src="1.png"/>
          <text value="11"/>
        </text>
        <text value="第二">
          <image src="2.png"/>
          <text value="22"/>
          <link href="1.html" text="nihao" />
        </text>
      </bundle>
    `
    struct = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<Nodes maxid=\"8\"><N id=\"0\" f=\"0\" t=\"根节点\"><N id=\"1\" t=\"&lt;br&gt;第\\n一\"><N id=\"5\" t=\"image\" i=\"1.png\"/><N id=\"2\" t=\"11\"/></N><N id=\"3\" t=\"第二\"><N id=\"6\" t=\"image\" i=\"2.png\"/><N id=\"4\" t=\"22\"/><N id=\"7\" t=\"nihao -- 1.html\"/></N></N></Nodes>\n"
    assert_equal struct,MapFileParser.xslt_transform_form_xml(xml,xslt)
  end

end
