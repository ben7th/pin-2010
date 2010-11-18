# Methods added to this helper will be available to all templates in the application.
module WebSiteHelper
  def web_site_introduction_info(web_site)
    blank_str = "暂无内容"
    return blank_str if web_site.blank?
    introduction = web_site.introduction
    return blank_str if introduction.blank?
    introduction.content.markdown_to_html
  end

  def build_site_info_json(url)
    ws_domain = URI.parse(url).host
    web_site = WebSite.find_by_domain(ws_domain)
    comments = Comment.url_equals(params[:url]).by_updated_at(:desc).limited(3)
    comments.map! do |comment|
      user = comment.creator
      {
        :id=>comment.id,:user=>{:id=>user.id,:name=>user.name,:avatar=>user.logo.url},
        :content=>comment.content,:updated_at=>comment.updated_at
      }
    end
    {:info=>web_site_introduction_info(web_site),:comments=>comments}
  end
end
