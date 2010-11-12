require 'test_helper'

class BookmarkEntryTest < ActiveSupport::TestCase

  test "创建 BookmarkEntry" do
    lifei = users(:lifei)
    url = "http://www.williamlong.info/archives/433.html"
    site = "williamlong.info"
    assert_difference(["BookmarkEntry.count","ShortUrl.count"],1) do
      Entry.create(:user=>lifei,:resource_meta=>{:type=>"BookmarkEntry",:data=>{:url=>url}})
    end
    entry = Entry.last
    bookmark_entry = BookmarkEntry.last
    assert_equal entry.user,lifei
    assert_equal entry.resource,bookmark_entry
    assert_equal bookmark_entry.site,site
  end

  test "获取土豆网视频的标题" do
    lifei = users(:lifei)
    urls = [
#      "http://www.tudou.com/programs/view/dBRzeu-x6mY/",
#      'http://www.tudou.com/programs/view/5Z6zNePRUy0/',
#      'http://www.tudou.com/programs/view/dGCxONYZbUU/',
#      'http://www.tudou.com/programs/view/u7JXKoKDzSM/',
#      'http://www.tudou.com/programs/view/6ltQpRTvmmk/',
#      'http://www.tudou.com/programs/view/2U6oFT1bL_o/',
#      'http://www.tudou.com/programs/view/VkN6i9qLY3I/',
#      'http://www.tudou.com/programs/view/ox-t55P3OKA/',
#      'http://www.tudou.com/programs/view/zfwhlgoHKU8/',
#      'http://www.tudou.com/programs/view/KbvsnbHhQqk/'
    ]
    urls.each do |url|
      test_todu(lifei,url)
    end
  end
  
  def test_todu(user,url)
    assert_difference(["BookmarkEntry.count","ShortUrl.count"],1) do
      Entry.create(:user=>user,:resource_meta=>{:type=>"BookmarkEntry",:data=>{:url=>url}})
    end
  end

end
