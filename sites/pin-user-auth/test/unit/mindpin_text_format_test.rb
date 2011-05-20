require 'test_helper'
class MindpinTextFormatTest < ActiveSupport::TestCase
  test "基本" do
    input = "你好"
    output = "<p>你好</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "换行 1" do
    input = "第一行\n第二行"
    output = "<p>第一行<br/>第二行</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "换行 2" do
    input = "第一行\n\n第二行"
    output = "<p>第一行</p><p>第二行</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "换行 3" do
    input = "第一行\n\n\n第二行"
    output = "<p>第一行</p><p>第二行</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "换行 4" do
    input = "第一行\n\n\n\n第二行"
    output = "<p>第一行</p><p>第二行</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "换行 5" do
    input = "第一行\n\n\n\n第二行\n\n\n第三行"
    output = "<p>第一行</p><p>第二行</p><p>第三行</p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "字体 1" do
    input = "*斜体*"
    output = "<p><em>斜体</em></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html

    input = "_斜体_"
    output = "<p><em>斜体</em></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "字体 2" do
    input = "**粗体**"
    output = "<p><strong>粗体</strong></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html

    input = "__粗体__"
    output = "<p><strong>粗体</strong></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test "字体 删除线" do
    input = "~~删除~~"
    output = "<p><del>删除</del></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

  test '链接 1' do
    input = 'An [example](http://url.com/ "Title")'
    output = "<p>An <a href=\"http://url.com/\" title=\"Title\">example</a></p>"
    assert_equal output , MindpinTextFormat.new(input).to_html
  end

end



