require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  test "获取字符串的所有前缀拆分" do
    clear_model(Entry,BookmarkEntry,Share,Using)
    lifei = users(:lifei)
    url_1 = "http://v.youku.com/v_show/id_XMTc1Nzg5NjU2.html"
    url_2 = "http://2.mms.blog.xuite.net/2/9/4/a/14156278/blog_165484/dv/9654813/9654813.mp3"
    content = " 分享视频 #{url_1} 分享音乐 #{url_2} "
    assert_difference(["Entry.count","BookmarkEntry.count"],2) do
      Entry.create(:user=>lifei,:resource_meta=>{:type=>"BookmarkEntry",:data=>{:url=>url_1}})
      Entry.create(:user=>lifei,:resource_meta=>{:type=>"BookmarkEntry",:data=>{:url=>url_2}})
    end
    assert_difference(["Share.count"],1) do
      Share.create(:content=>content,:creator=>lifei)
    end
    assert_equal Using.count,2
    share = Share.last
    assert_equal share.usings.size,2
  end
  
end

