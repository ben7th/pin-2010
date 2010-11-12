require "nokogiri"
class BrowseHistory < ActiveRecord::Base
  belongs_to :user,:foreign_key => "user_id"
  validates_presence_of :user_id
  validates_presence_of :url

  named_scope :from_size, lambda{ |from,size|
    {:limit=>" #{from},#{size}"}
  }

  # 创建历史记录
  def self.find_or_create(user,params)
    bh = BrowseHistory.find_by_user_id_and_url(user.id,params['url'])
    # 如果已经存在，更新它的时间
    if bh
      bh.update_attributes(:updated_at=>Time.now,:title=>params['title'])
      return bh
    end
    # 尚未创建的新建记录
    BrowseHistory.create(:user_id=>user.id,:url=>params['url'],:title=>params['title'])
  end

  require 'uri'
  def domain
    URI.parse(URI.encode(self.url)).host
  end

  def web_site
    WebSite.find_by_domain(domain)
  end

  def nokogiri_html
    Nokogiri::XML(content)
  end

  def rss_feeds
    sina_rss
  end

  def javaeye_rss
    nokogiri_html.css("div#rss").map do |rss|
      {:url=>"http://#{self.domain}/rss",:title=>"rss"}
    end
  end

  def sina_rss
    nokogiri_html.css(%`link[type="application/rss+xml"]`).map do |rss|
      {:url=>rss['href'],:title=>"rss"}
    end
  end

  def links
    nokogiri_html.css("a").map do |link|
      href = check_link(link['href'])
      text = link.text.blank? ? href : link.text
      {:href=>href,:title=>text} 
    end
  end

  # 查看并补齐url地址
  def check_link(href)
    return self.domain if href.blank?
    return href if href.match("http://")
    File.join("http://",self.domain,href)
  end

  def images
    nokogiri_html.css("img").map do |image|
      image
    end
  end

end
