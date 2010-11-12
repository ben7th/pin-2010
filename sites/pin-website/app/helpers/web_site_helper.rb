# Methods added to this helper will be available to all templates in the application.
module WebSiteHelper
  def web_site_introduction_info(web_site)
    blank_str = "暂无内容"
    return blank_str if web_site.blank?
    introduction = web_site.introduction
    return blank_str if introduction.blank?
    introduction.content.markdown_to_html
  end
end
