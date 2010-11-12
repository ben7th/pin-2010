class WebSite < ActiveRecord::Base

  validates_presence_of :domain

  @logo_path = "#{UserBase::LOGO_PATH_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  @logo_url = "#{UserBase::LOGO_URL_ROOT}:class/:attachment/:id/:style/:basename.:extension"
  has_attached_file :logo,:path => @logo_path,:url => @logo_url,:default_url => "/images/logo/default_:class_:style.png"

  def self.create_web_site(domain)
    web_site = WebSite.find_by_domain(domain)
    web_site = WebSite.create(:domain=>domain) if web_site.blank?
    return web_site
  end

  after_create :set_page_rank
  def set_page_rank
#    p "page rank"
#    self.page_rank = GooglePageRank.new(self.domain).page_rank
#    self.save
#    return true
  end

  after_create :set_logo
  def set_logo
    response = HandleGetRequest.get_response_from_url("http://#{self.domain}/favicon.ico")
    return true if response.blank?
    file_name = "/tmp/#{domain.to_s.gsub(".","_")}_favicon.ico"
    temp_logo_file = File.open(file_name,"w+")
    temp_logo_file.puts(response)
    self.logo = temp_logo_file
    self.save
    temp_logo_file.close
    FileUtils.rm(file_name)
    return true
  end

  after_create :add_attributes_to_web_site
  def add_attributes_to_web_site
    response = HandleGetRequest.get_response_from_url("http://#{self.domain}/")
    xml_content = Nokogiri::HTML(response)
    title = xml_content.css("title")[0].nil? ? domain : xml_content.css("title")[0].inner_html
    key_words,description = "",""
    xml_content.css("meta").each do |meta|
      name_attr = meta.attribute("name")
      next if name_attr.blank?
      case name_attr.value.downcase
      when "keywords" then key_words = meta.attribute("content").value
      when "description" then description = meta.attribute("content").value
      end
    end
    self.update_attributes(:title=>title,:key_words=>key_words,:description=>description)
    return true
  end

  include Feeling::FeelableMethods
  include Introduction::IntroductableMethods
end