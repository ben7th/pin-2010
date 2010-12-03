module GlobalUtil
  def randstr(length=8)
    base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size = base.size
    re = ''<<base[rand(size-10)]
    (length-1).times  do
      re<<base[rand(size)]
    end
    re
  end

  def text_num(text, num)
    num == 0 ? "#{text}" : "#{text}(#{num})"
  end

  def get_flash_error(record)
    begin
      arr =  record.errors.to_a
      original_title_id = randstr

      used_fields = [arr[0][0]]

      lis = ''
      1.upto arr.length-1 do |i|
        field = arr[i][0]
        if !used_fields.include?(field)
          info = arr[i][1]
          lis << "<li>#{info}</li>"
          used_fields<<field
        end
      end

      others_count = used_fields.length - 1

      str0 = "#{arr[0][1]} "
      str1 = "<div class='others tip' tip='##{original_title_id}'>#{others_count} 其他..</div>"
      str2 = "<div id='#{original_title_id}' class='hide'><ul>#{lis}</ul></div>"

      return "#{str0}#{str1}#{str2}" if others_count > 0
      return "#{str0}"

    rescue Exception => ex
      "数据验证错误"
    end

  end
end
