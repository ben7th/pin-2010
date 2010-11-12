require "uri"
class WebSiteVisit < ActiveRecord::Base
  belongs_to :user,:foreign_key=>"user_id"
  belongs_to :web_site,:foreign_key=>"web_site_id"

  def self.create_new_record(user,url)
    domain = URI.parse(url).host
    web_site = WebSite.create_web_site(domain) # 如果存在返回存在的，如果不存在，新建之
    web_site_visit = WebSiteVisit.find_by_user_id_and_web_site_id(user.id,web_site.id)
    if web_site_visit
      return web_site_visit.update_attributes(:count=>web_site_visit.count+1)
    end
    WebSiteVisit.create(:user_id=>user.id,:web_site_id=>web_site.id,:count=>1)
  end
  
end
