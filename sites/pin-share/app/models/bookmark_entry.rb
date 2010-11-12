class BookmarkEntry < ActiveRecord::Base

  validates_presence_of :url
  validates_presence_of :site

  SNAPSHOT_PATH = "/web/snapshots/"

  before_validation :set_site
  def set_site
    self.site = self.url.url_to_site
  end

  before_create :parse_video_info
  def parse_video_info
    video_info = VideoSiteUrlParse.parse_url(self.url || "")
    if !video_info.nil?
      self.video_src = video_info[:video_src]
      self.image_src = video_info[:image_src]
      self.title = video_info[:title]
    end
  end

  after_create :change_url_to_code
  def change_url_to_code
    ShortUrl.get_short_url(self.url)
    return true
  end

  def self.has_video?(url)
    !!VideoSiteUrlParse.parse_url(url)
  end

  def self.is_audio_url?(url)
#    AudioParse.is_audio_url?(url)
    str_arr = URI.parse(url).path.split(".")
    return false if str_arr.size <= 1
    type = str_arr.last
    ["mp3"].include?(type.downcase)
  end

  # 找到 user 针对 url 的书签资源
  def self.f_by_user_and_url(user,url)
    entries = Entry.bookmark_url_is(url).user_of(user)
    return entries[0].resource if !entries.blank?
    return nil
  end

  # 找到和 url 的 site 相同的书签资源的 所有 URL
  def self.relative_url(url)
    site = url.url_to_site
    raise "url 不合法" if !site
    urls = BookmarkEntry.find_all_by_site(site).map{|bookmark_entry| bookmark_entry.url}.uniq
    urls.delete url
    return urls
  end

  # 根据url得到网页的快照
  require 'net/http'
  def get_snapshot(url,options)
    begin
      file_path = "#{BookmarkEntry::SNAPSHOT_PATH}/#{self.id}.html"
      return File.open(file_path).readlines if File.exist?(file_path)
      url_str = URI.parse(url)
      req = Net::HTTP::Get.new(url_str.path,{'accept'=>'text/html','user-agent'=>'Mozilla/5.0'})
      response = Net::HTTP.start(url_str.host, url_str.port) {|http|
        http.request(req)
      }
      return handle_with_response(url,file_path,response,options)
    rescue Exception => ex
      p ex
    end
  end

  def handle_with_response(url,file_path,response,options)
    case response
    when Net::HTTPSuccess,Net::HTTPOK
      file = File.new(file_path,"w")
      web_content = response.body
      file.puts(web_content)
      file.close
      return web_content
    when Net::HTTPRedirection
      raise '循环重定向' if response['location'] == url
      redirect_count = options[:redirect_count] || 0
      raise '重定向次数过多' if redirect_count > 5
      return get_snapshot(response['location'],:redirect_count=>redirect_count+1)
    else
    end
  end

  def self.search(keyword,user)
    BookmarkEntry.find(:all,:conditions=>[' title like ? ',"%#{keyword}%"]).map{|bookmark_entry|bookmark_entry.entry if bookmark_entry.entry&&bookmark_entry.entry.user == user&&bookmark_entry.entry.deleted_at.blank?}.compact
  end

  def is_video_url?
    !!self.video_src
  end

  def is_audio_url?
    BookmarkEntry.is_audio_url?(self.url)
  end

  # 得到这个bookmark_entry 的url所对应的short_url
  def short_url_str
    ShortUrl.get_short_url(self.url)
  end

  include Entry::ResourceMethods
  include Share::ShareableMethods
end