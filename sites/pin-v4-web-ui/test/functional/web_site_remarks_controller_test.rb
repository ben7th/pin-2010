require 'test_helper'

class WebSiteRemarksControllerTest < ActionController::TestCase

  test "给 web_site 增加评注" do
    lifei = users(:lifei)
    url = "http://www.williamlong.info/archives/433.html"
    site = "www.williamlong.info"
    first_content = "这个网页的内容对我帮助很大"
    session[:user_id] = lifei
    assert_difference(["WebSite.count","Comment.count"],1) do
      post :create,:domain=>site,:comment=>{:content=>first_content}
    end
    web_site = WebSite.last
    comment = Comment.last
    
    assert_equal web_site.comments.count,1
    assert web_site.comments.include?(comment)
    
    assert_equal web_site.domain,site

    assert_equal comment.creator,lifei
    assert_equal comment.content,first_content

    second_content = "观点很好"
    assert_difference(["Comment.count"],1) do
      assert_difference(["WebSite.count"],0) do
        post :create,:domain=>site,:comment=>{:content=>second_content}
      end
    end

    web_site = WebSite.last
    comment = Comment.last
    
    assert_equal web_site.comments.count,2
    assert web_site.comments.include?(comment)
    
    assert_equal web_site.domain,site

    assert_equal comment.creator,lifei
    assert_equal comment.content,second_content

    comments = web_site.comments.find(:all,:limit=>1,:order=>"created_at")
    assert_equal comments.count,1
  end
end
