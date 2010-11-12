require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  test "批量删除资源信息" do
    clear_model(Entry,TextEntry)
    lifei = users(:lifei)
    login(lifei)
    re_1,re_2,re_3=nil,nil,nil
    assert_difference(['Entry.count','TextEntry.count'],3) do
      re_1 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_1",:content=>"文本内容_1"}})
      re_2 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_2",:content=>"文本内容_2"}})
      re_3 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_3",:content=>"文本内容_3"}})
    end
    assert_difference(['Entry.count'],-3) do
      delete :destroys,:entry_ids=>[re_1.id,re_2.id,re_3.id]
    end
  end
  
  test "批量修改资源标签" do
    clear_model(Entry,TextEntry)
    lifei = users(:lifei)
    login(lifei)
    re_1,re_2,re_3=nil,nil,nil
    assert_difference(['Entry.count','TextEntry.count'],3) do
      re_1 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_1",:content=>"文本内容_1"}})
      re_2 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_2",:content=>"文本内容_2"}})
      re_3 = Entry.create!(:user => lifei,:resource_meta=>{:type=>"TextEntry",:data=>{:title=>"文本标题_3",:content=>"文本内容_3"}})
    end
    ids = [re_1.id,re_2.id,re_3.id]
    get :edit_tags,:entry_ids=>ids
    assert_response :success
    put :update_tags,:entry_ids=>ids,:tags_str=>"记号"
    tag = Tag.last
    assert_equal tag.value,"记号"
    assert_equal re_1.tags.count,1
    assert re_1.tags.include?(tag)
    assert_equal re_2.tags.count,1
    assert re_2.tags.include?(tag)
    assert_equal re_3.tags.count,1
    assert re_3.tags.include?(tag)
  end
  
  test "创建文本资源" do
    clear_model(Entry,TextEntry)
    lifei = users(:lifei)
    login(lifei)
    assert_difference(['Entry.count','TextEntry.count'],1) do
      post :create,:entry=>{:resource_meta=>{:type=>"TextEntry",:data=>{:content=>"文本资源创建测试"}}}
    end
    text_entry = TextEntry.last
    entry = Entry.last
    assert_equal text_entry.content,"文本资源创建测试"
    assert_equal text_entry.entry,entry
    assert_equal entry.creator,lifei
  end
  
  
  #   这个地址http://blog.sina.com.cn/rss/twocold.xml
  #   是一个直接的RSS源
  test "订阅rss" do
    clear_model(Entry,SubscriptionEntry,RssFeed,RssItem)
    url = "http://blog.sina.com.cn/rss/twocold.xml"
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,1
    assert_equal RssFeed.count,1
    assert_equal SubscriptionEntry.count,1
    # 重复创建的话
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,1
    assert_equal RssFeed.count,1
    assert_equal SubscriptionEntry.count,1
  end

  # 这个地址http://blog.sina.com.cn/twocold
  # 是一个直接的RSS源
  test "订阅rss，输入的地址不是直接的rss源" do
    clear_model(Entry,SubscriptionEntry,RssFeed,RssItem)
    url = "http://blog.sina.com.cn/twocold"
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,1
    assert_equal RssFeed.count,1
    assert_equal SubscriptionEntry.count,1
    # 重复创建的话
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,1
    assert_equal RssFeed.count,1
    assert_equal SubscriptionEntry.count,1
  end

  test "订阅rss，输入的地址无效" do
    clear_model(Entry,SubscriptionEntry,RssFeed,RssItem)
    url = "http://www.sina.com.cn/contactus.html"
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,0
    assert_equal RssFeed.count,0
    assert_equal SubscriptionEntry.count,0
  end

  test "订阅blog.donews.com的rss" do
    url = "http://blog.donews.com/sosmoke/"
    create_feed_and_entry(url)
  end

  test "处理简单链接/haha=>http://www.163.com/haha 调试输出使用测试" do
    url = "http://windytwang.javaeye.com/"
    create_feed_and_entry(url)
  end

  def create_feed_and_entry(url)
    clear_model(Entry,SubscriptionEntry,RssFeed,RssItem)
    url = url
    lifei = users(:lifei)
    session[:user_id] = lifei.id
    post :create,:type=>"subscription",:url=>url
    assert_equal Entry.count,1
    assert_equal RssFeed.count,1
    assert_equal SubscriptionEntry.count,1
  end

  def login(user)
    session[:user_id]=user.id
  end
end
