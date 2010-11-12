require 'test_helper'
class StringUtilTest < ActiveSupport::TestCase
  # "abc"=>["a","ab","abc"]
  # "大家好"=>["大","大家","大家好"]
  test "获取字符串的所有前缀拆分" do
    input = [
      "a","啊",
      "aa","啊啊",
      "ab","啊哈",
      "abc","啊哈呵",
      "aaaa","哈哈哈哈"
    ]
    output = [
      ["a"],["啊"],
      ["a","aa"],["啊","啊啊"],
      ["a","ab"],["啊","啊哈"],
      ["a","ab","abc"],["啊","啊哈","啊哈呵"],
      ["a","aa","aaa","aaaa"],["哈","哈哈","哈哈哈","哈哈哈哈"]
    ]
    input.each_with_index do |str, index|
      assert_equal str.to_prefixs,output[index]
    end
  end
end

