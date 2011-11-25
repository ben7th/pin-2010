class MindpinDiff
  require 'diff/lcs'

  attr_reader :str_1, :str_2, :diffs

  def initialize(str_1, str_2)
    @str_1 = str_1
    @str_2 = str_2

    # 字符数组，用于作为算法输入参数
    @chars_arr_1 = @str_1.chars.to_a
    @chars_arr_2 = @str_2.chars.to_a

    # diffs
    @diffs = Diff::LCS.diff(@chars_arr_1, @chars_arr_2)

    # diffs_hash
  end

  def diffs_hash
    @diffs_hash ||= @diffs.map {|change_arr|
      re = []
      change_arr.each do |change|
        action = change.action
        element = change.element
        position = change.position

        last_change = re.last

        if last_change.blank? || last_change[:action] != action
          re << {
            :action=>action,
            :positions=>[position],
            :str=>element
          }
        elsif last_change[:action] == action
          last_change[:positions] = last_change[:positions] + [position]
          last_change[:str] = last_change[:str] + element
        end
      end
      re
    }
  end

  def diffs_desc
    diffs_hash.map do |change_arr|
      change_arr.map do |change|
        "#{change[:action]}#{change[:positions].to_json}#{change[:str]}"
      end
    end
  end

  def diffs_changes_desc
    diffs_hash.map do |change_arr|
      change_arr.map do |change|
        case change[:action]
        when '-'
          "<del class='differ'>#{change[:str]}</del>"
        when '+'
          "<ins class='differ'>#{change[:str]}</ins>"
        end
      end
    end
  end

  def diff_arr
    result_chars_arr = @chars_arr_1.clone

    prefix_del_arr = []

    # 先减
    diffs_hash.each do |change_arr|
      change_arr.each do |change|
        positions = change[:positions]

        case change[:action]
        when '-'
          del_str = "<del class='differ'>#{change[:str]}</del>"
          positions.each do |i|
            result_chars_arr[i] = ''
          end
          index = positions[0]-1
          if index >= 0
            result_chars_arr[index] = result_chars_arr[index] + del_str
          else
            prefix_del_arr << del_str
          end
        end
      end
    end
    result_chars_arr = result_chars_arr - ['']

    result_chars_arr = [''] if result_chars_arr.blank?

    # 后加
    diffs_hash.each do |change_arr|
      change_arr.each do |change|
        positions = change[:positions]

        case change[:action]
        when '+'
          ins_str = "<ins class='differ'>#{change[:str]}</ins>"
          index = positions[0]-1
          if index >= 0
            result_chars_arr[index] += ins_str
            result_chars_arr[index] = [result_chars_arr[index]] + ['']*positions.length
            result_chars_arr.flatten!
          else
            result_chars_arr[0] = ins_str + result_chars_arr[0]
            result_chars_arr[0] = [result_chars_arr[0]] + ['']*positions.length
            result_chars_arr.flatten!
          end
          
          raise 'zerooo' if result_chars_arr.include? nil
        end
      end
    end

    (prefix_del_arr + result_chars_arr).compact
  end

  def diff_arr_raw
    i=-1
    raw = diff_arr.map{|x|
      i+=1
      "#{i}#{x}"
    }
    raw * ','
  end

  def html
    re = ''
    if @str_1 == @str_2
      re = @str_1
    else
      re = diff_arr*''
    end

    re.gsub!(/\n/,'<br/>')

    doc = Nokogiri::XML.fragment("<div>#{re}</div>")

    doc.css('ins br,del br').each do |br_elm|
      br_elm.after("<div class='br'></div>")
      br_elm.remove
    end

    doc.at_css('div').inner_html
  rescue Exception => ex
    return '文本解析错误' if RAILS_ENV == 'production'
    raise ex
  end

  def self.test1
    str1 = %~
这次调整之后，搜索结果更准确，可读性更好。
可以通过网站顶部的搜索框，随时对主题进行搜索。
试试看吧：
http://www.mindpin.com/search_feeds?q=mindpin
Epic lolcat fail!
    ~

    str2 = %~
调整之后，搜索结果更准确。
可以通过网站右边栏的搜索框，随时对主题进行搜索。
思维导图的搜索和主题的搜索整合在一起了
试试看吧：
http://www.mindpin.com/search/mindpin
Epic wolfman fail!
节日快乐！
    ~

    diff = MindpinDiff.new(str1,str2)

    diff.html
  end

  def self.test2
    str1 ="春哥纯爷们铁血真汉子人民好兄弟"

    str2 ="春哥纯爷们人民好兄弟父亲好儿子很好"

    diff = MindpinDiff.new(str1,str2)

    diff.html
  end

  #-------------------TAGS-------------------
  def self.diff_tag_ids(ids1,ids2)
    tags1 = Tag.find_all_by_id(ids1)
    tags2 = Tag.find_all_by_id(ids2)
    diffs = Diff::LCS.diff tags1,tags2

    result_arr = tags1.map do |tag|
      {:action=>'',:tag=>tag}
    end

    prefix_del_arr = []

    # 先减
    diffs.each do |change_arr|
      change_arr.each do |change|
        position = change.position

        case change.action
        when '-'
          index = position - 1
          elm = {:action=>'diff-del',:tag=>change.element}
          result_arr[position] = nil
          if index >= 0
            result_arr[index] = [
              result_arr[index],
              elm
            ]
          else
            prefix_del_arr << elm
          end
        end
      end
    end

    result_arr.compact!

    # 后加
    diffs.each do |change_arr|
      change_arr.each do |change|
        position = change.position

        case change.action
        when '+'
          elm = {:action=>'diff-ins',:tag=>change.element}
          result_arr.insert(position,elm)
        end
      end
    end

#    (prefix_del_arr + result_arr).flatten.map { |elm|
#      "<b>#{elm[:action]}</b>#{elm[:tag].name}"
#    }*','

    (prefix_del_arr + result_arr).flatten.compact
  rescue Exception => ex
    return [] if RAILS_ENV == 'production'
    raise ex
  end

end