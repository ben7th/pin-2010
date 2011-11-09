def mup_ap(content)
  ap content
end

# 产生一个随机字符串
def randstr(length=8)
  base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  size = base.size
  re = ''<<base[rand(size-10)]
  (length-1).times  do
    re<<base[rand(size)]
  end
  re
end

# 从验证失败的记录中获得错误显示信息
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

# 性能检测函数
# 用法：
# benchmark do
#   ...
# end
def benchmark(&block)
  bm = Benchmark.realtime do
    yield block
  end
  p bm
end

# 获取某个目录下的所有子目录
def get_all_dir(basedir)
  dirs = []
  Find.find(basedir) do |path|
    if FileTest.directory?(path)
      dirs << path
    end
  end
  dirs
end

# utf8下将中文当成两个字符处理的自定义的truncate方法
# 取自javaeye上庄表伟和quake wang的方法
# 由于quake wang的方法在需要截取的字符数大于30时有较严重的效率问题，导致卡死进程
# 因此需要截取长度大于30时使用庄表伟的方法
def truncate_u(text, length = 30, truncate_string = "...")
  if length >= 30
    l=0
    char_array=text.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return text
  else
    if r = Regexp.new("(?:(?:[^\xe0-\xef\x80-\xbf]{1,2})|(?:[\xe0-\xef][\x80-\xbf][\x80-\xbf])){#{length}}", true, 'n').match(text)
      return r[0].length < text.length ? r[0] + truncate_string : r[0]
    else
      return text
    end
  end
end

# 阿里云文件存储服务的请求签名方法
require 'openssl'
require 'base64'
def ali_oss_sign(verb, key, date, res)
  digest  = OpenSSL::Digest::Digest.new('sha1')

  md5 = ''
  ty = ''
  header = ''

  str = "#{verb}\n#{md5}\n#{ty}\n#{date}\n#{header}#{res}"
  bytemac = OpenSSL::HMAC.digest(digest, key, str)
  res = Base64.encode64(bytemac).strip
end

def ali_get_all(id, key)
  date = Time.now.gmtime.strftime('%a, %d %b %Y %H:%M:%S %Z')

  Net::HTTP.start('storage.aliyun.com') do |http|
    r = http.get('/','Authorization'=>"OSS #{id}:#{ali_oss_sign('GET', key, date, '/')}",'Date'=>date)
    puts r.body
  end
end

def put_bucket(id, key, bucket)
  date = Time.now.gmtime.strftime('%a, %d %b %Y %H:%M:%S %Z')

  Net::HTTP.start('storage.aliyun.com') do |http|
    r = http.put("/#{bucket}",'Authorization'=>"OSS #{id}:#{ali_oss_sign('PUT', key, date, "/#{bucket}")}",'Date'=>date)
    puts r.body
  end
end