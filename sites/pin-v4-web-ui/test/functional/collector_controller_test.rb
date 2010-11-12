require 'test_helper'

class CollectorControllerTest < ActionController::TestCase

  test "创建网页书签" do
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    url = "http://you.video.sina.com.cn/b/16972162-1239095354.html"
    site = "video.sina.com.cn"
    assert_equal BookmarkEntry.f_by_user_and_url(lifei,url),nil
    assert_difference(['Entry.count','BookmarkEntry.count'],1) do
      post :create,:entry=>{:resource_meta=>{:type=>"BookmarkEntry",:data=>{:url=>url}}}
    end
    bookmark_entry = BookmarkEntry.last
    assert_equal bookmark_entry.url,url
    assert_equal bookmark_entry.site,site
    assert_equal BookmarkEntry.f_by_user_and_url(lifei,url),bookmark_entry
  end
end
