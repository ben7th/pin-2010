require 'test_helper'

class BugTest < ActiveSupport::TestCase

  test "获取用户的浏览器类型" do
    bug_ie8 = Bug.new(:user_agent=>"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)")
    bug_ie7 = Bug.new(:user_agent=>"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727)")
    bug_firefox36 = Bug.new(:user_agent=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6")
    bug_chrome_5 = Bug.new(:user_agent=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.99 Safari/533.4")
    bug_safari = Bug.new(:user_agent=>"Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16")
    assert_equal bug_ie8.browser_type,"MSIE 8.0"
    assert_equal bug_ie7.browser_type,"MSIE 7.0"
    assert_equal bug_firefox36.browser_type,"Firefox/3.6.6"
    assert_equal bug_chrome_5.browser_type,"Chrome/5.0.375.99"
    assert_equal bug_safari.browser_type,"Safari/533.16"
  end

  test "对一个bug 进行 '顶' 操作" do
    lifei = users(:lifei)
    lucy = users(:lucy)
    chengliwen = users(:chengliwen)
    assert_difference("Bug.count",1) do
      Bug.create!(:content=>"是男人就顶啊",:user_id=>lucy.id)
    end
    bug = Bug.last

    assert_difference("Favorite.count",1) do
      # 创建成功
      assert_equal true,bug.favor(lifei)
    end
    favor = Favorite.last
    assert_equal favor.user_id,lifei.id
    assert_equal favor.num,1

    assert_difference("Favorite.count",0) do
      # 创建失败
      assert_equal false,bug.favor(lifei)
    end
    favor = Favorite.last
    assert_equal favor.user_id,lifei.id
    assert_equal favor.num,1

    assert_difference("Favorite.count",1) do
      # 创建成功
      assert_equal true,bug.favor(chengliwen)
    end
    favor = Favorite.last
    assert_equal favor.user_id,chengliwen.id
    assert_equal favor.num,1

    # 把创建和修改时间提前 12 个小时
    time = favor.created_at
    time = time-(24*60*60)-1
    Favorite.record_timestamps = false
    favor.update_attributes(:created_at=>time,:updated_at=>time)
    Favorite.record_timestamps = true

    assert_difference("Favorite.count",0) do
      # 创建成功
      assert_equal true,bug.favor(chengliwen)
    end
    favor = Favorite.last
    assert_equal favor.user_id,chengliwen.id
    assert_equal favor.num,2
    # 被顶的总数
    assert_equal bug.favor_count,3
  end

end
