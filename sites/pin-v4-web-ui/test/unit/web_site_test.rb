require 'test_helper'

class WebSiteTest < ActiveSupport::TestCase

  def create_web_site
    site = "www.javaeye.com"
    assert_difference("WebSite.count",1) do
      WebSite.create!(:domain=>site)
    end
    web_site = WebSite.last
    assert_equal web_site.domain,site
    return web_site
  end

  test "创建 WebSite" do
    create_web_site
  end

  test "给 WebSite 增加评论" do
    lifei = users(:lifei)
    web_site = create_web_site
    content = "这个页面的内容对我很有帮助"
    assert_difference("web_site.comments.count",1) do
      web_site.comments.create(:creator=>lifei,:content=>content)
    end
    comment = Comment.last
    assert_equal comment.creator,lifei
    assert_equal comment.content,content
  end

end
