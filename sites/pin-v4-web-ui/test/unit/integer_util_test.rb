require 'test_helper'
class IntegerUtilTest < ActiveSupport::TestCase
  
  test "阿拉伯数字转换成汉语数字" do
    sources = [
      1,2,3,4,5,6,7,8,9,0,
      10,15,20,24,98,
      100,101,112,156,999,
      1000,1001,1020,1035,1105,1789,
      10000,10002,12345,
      100000,100504,145678,
      1000000,10000000,100000000,102340567,
      1000000000
    ]

    results = [
      '一','二','三','四','五','六','七','八','九','零',
      '十','十五','二十','二十四','九十八',
      '一百','一百零一','一百一十二','一百五十六','九百九十九',
      '一千','一千零一','一千零二十','一千零三十五','一千一百零五','一千七百八十九',
      '一万','一万零二','一万二千三百四十五',
      '十万','十万零五百零四','十四万五千六百七十八',
      '一百万','一千万','一亿','一亿零二百三十四万零五百六十七',
      '十亿'
    ]

    sources.each_index do |index|
      num = sources[index]
      result = results[index]
      assert_equal num.to_cn_str , result
    end
  end

  test '把数字转成字符串，并且拆分成四个字符一组的数组' do
    sources = [
      1,2,3,4,5,6,7,8,9,0,
      12,234,3456,56789,
      678901,7890123,89012345,
      1000234,500600700,
      901234567
    ]

    results = [
      ['1'],['2'],['3'],['4'],['5'],['6'],['7'],['8'],['9'],['0'],
      ['12'],['234'],['3456'],['5','6789'],
      ['67','8901'],['789','0123'],['8901','2345'],
      ['100','0234'],['5','0060','0700'],
      ['9','0123','4567']
    ]

    sources.each_with_index do |source,index|
      result = results[index].map{|x| x.split('')}
      # ['9','0123','4567'] -> [['9'],['0','1','2','3'],['4','5','6','7']]
      assert_equal result,Integer.split_by_4_digital(source)
    end
  end

  test '四位数字字符串转换成汉字字符串' do
    sources = [
      '1234',
      '1230','1204','1034','0234',
      '1200','1004','0034','1030','0204','0230',
      '1000','0001','0100','0010',
      '0000'
    ]

    results = [
      '一千二百三十四',
      '一千二百三十','一千二百零四','一千零三十四','零二百三十四',
      '一千二百','一千零四','零三十四','一千零三十','零二百零四','零二百三十',
      '一千','零一','零一百','零一十',
      '零'
    ]

    sources.each_index do |index|
      source = sources[index].split('')
      # ['4567'] -> ['4','5','6','7']
      result = results[index]
      assert_equal result,Integer.transform_4digitals_to_cn(source)
    end
  end

  test '转换一位数字为汉字字符串' do
    sources = [
      [2,0],[2,1],[2,2],[2,3],
      [0,0],[0,1],[0,2],[0,3]
    ]

    results = [
      '二','二十','二百','二千',
      '零','零','零','零'
    ]

    sources.each_with_index do |source,index|
      result = results[index]
      assert_equal result,Integer.trans_digital_to_cn(source[0],source[1])
    end
  end

  test '连接四位组转换所得的字符串，并添加 万 亿 单位' do
    sources = [
      ['一','一千二百三十四'],
      ['二','三千四百七十五','零八百三十六'],
      ['一','零','零']
    ]

    results = [
      '一万一千二百三十四',
      '二亿三千四百七十五万零八百三十六',
      '一亿零零'
    ]

    sources.each_with_index do |source,index|
      result = results[index]
      assert_equal result,Integer.join_wan_and_yi(source)
    end
  end
end
