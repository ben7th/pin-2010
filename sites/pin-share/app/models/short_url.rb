class ShortUrl < ActiveRecord::Base

  validates_presence_of :url
  validates_uniqueness_of :url
  
  before_create :check_code
  def check_code
    self.code = self.create_a_not_existed_code
  end

  # 检测url是否本站
  def self.is_in_this_site?(url)
    return !!url.match(THIS_SITE)
  end

  # 如果 url 是 short_url， 找到它的原始地址
  # 如果 url 不是 short_url，不做处理，返回 url
  def self.original_url(url)
    if self.is_in_this_site?(url)
      code = url.gsub("#{THIS_SITE}url/","")
      su = ShortUrl.find_by_code(code)
      return su.url if su
    end
    return url
  end

  # 根据url返回它对应的short_url
  def self.get_short_url(url)
    short_url = ShortUrl.find_by_url(url)
    if short_url.blank?
      short_url = ShortUrl.create(:url=>url)
    end
    return short_url.short_url_str
  end

  # 得到url的code
  def self.short(str,length=4)
    base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    size = base.size
    md5str = Digest::MD5.digest(str)

    re = ''
    len = [md5str.length,length].min - 1

    0.upto len do |i|
      j = md5str[i] % size
      re << base[j]
    end

    re
  end


  # 查找这个code是否在数据库中存在，如果存在了，
  # 那么生成一个确保不存在的
  def create_a_not_existed_code
    code = ShortUrl.short(self.url)
    # 数据库中如果存在，则重新创建，确保唯一性
    while true
      return code if !ShortUrl.find_by_code(code)
      code = ShortUrl.short(self.url,code.length + 1)
    end
  end

  # 返回这个short_url对应的地址
  def short_url_str
    return File.join(THIS_SITE,"url/#{self.code}")
  end

end
