# To change this template, choose Tools | Templates
# and open the template in the editor.

class MindmapsRankTendencyChart

  SPLIT_VALUE = 11
  attr_accessor :group_hash

  def initialize(mindmaps)
    @mindmaps = mindmaps
    @group_hash = {"0"=>0,"0~1"=>0,"1~2"=>0,"2~3"=>0,"3~4"=>0,"4~5"=>0,"5~6"=>0,"6~7"=>0,"7~8"=>0,"8~9"=>0,"9~10"=>0}
    groups_of_mindmaps
  end

  # 分组
  # 根据rank值分成11 组，0 0-1 1-2 .... 9-10
  def groups_of_mindmaps
    @mindmaps.each do |mindmap|
      key = hash_key_of(mindmap)
      @group_hash[key] += 1
    end
    @group_hash
  end

  # 范围值（如果按照5分组）：0，1-5，6-10
  def keys
    @group_hash.sort.map{|arr|arr[0]}
  end

  # 每个范围中对应的 mindmaps的数量
  def values
    @group_hash.sort.map{|arr|arr[1]}
  end

  # 找出最大的rank值
  def max_rank
    @mindmaps.map{|mindmap|mindmap.rank.to_f}.max
  end

  # 随机生成颜色值,用于饼状图
  def color_array
    array = []
    0.upto(@group_hash.keys.count-1){|i|array[i]="##{rand_16_value+rand_16_value+rand_16_value}"}
    array
  end

  # 随机16进制字符串
  def rand_16_value
    rand(255).to_s(16)
  end

  # 判断某个mindmap的rank值所在的值区间
  def hash_key_of(mindmap)
    rank_value = mindmap.rank.to_f
    case rank_value
    when 0 then return "0"
    when 0.1..1 then return "0~1"
    when 1.1..2 then return "1~2"
    when 2.1..3 then return "2~3"
    when 3.1..4 then return "3~4"
    when 4.1..5 then return "4~5"
    when 5.1..6 then return "5~6"
    when 6.1..7 then return "6~7"
    when 7.1..8 then return "7~8"
    when 8.1..9 then return "8~9"
    when 9.1..10 then return "9~10"
    else
      return "0"
    end
  end

end
