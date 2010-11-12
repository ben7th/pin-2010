require 'test_helper'

class WebSiteIntroductionTest < ActiveSupport::TestCase

  test "分段测试" do
    data = [
      ["##",["##"]],
      ["#",["#"]],
      ["123",["123"]],
      ["#123",["#123"]],
      ["\n#123#123",["#123#123"]],
      ["\n\t\n   \n#123",["#123"]],
      ["#123\r\n#",["#123\n","#"]],
      ["####1212\n\n\n####\n\t\t#",["####1212\n\n\n","####\n        #"]]
    ]
    data.each do |input_output|
        test_markdown_parags(input_output[0],input_output[1])
    end
  end

  def test_markdown_parags(input,output)
    assert_equal input.markdown_paragraphs,output
  end
end