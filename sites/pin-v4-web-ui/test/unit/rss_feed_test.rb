require 'test_helper'

class RssFeedTest < ActiveSupport::TestCase

  test "添加rss源---直接的rssfeed源" do
    clear_model(RssFeed,RssItem,SubscriptionEntry,Entry)
    url = "http://renzhiqiang.blog.sohu.com/rss"
    RssFeed.create_rss_feed(url)
    assert_equal RssFeed.count,1
    # 同时创建一个subscription_entry
    assert_difference(['Entry.count','SubscriptionEntry.count'],1) do
      SubscriptionEntry.create_subscription_entry(users(:lifei),RssFeed.last)
    end
  end

  test "添加rss源---另一个直接的rssfeed源" do
    url = "http://mixiaole.blogbus.com/index.rdf"
    create_feed(url)
  end

  test "添加rss源---从网站中获取的源" do
    url = "http://juedui100.blogbus.com/"
    create_feed(url)
  end

  test "添加rss源---从javaeye网站中获取的直接源" do
    url = "http://robbin.javaeye.com/rss"
    create_feed(url)
  end

  test "添加rss源---从javaeye网站中获取的包含源的网页" do
    url = "http://robbin.javaeye.com/"
    create_feed(url)
  end

  test "添加rss源---从javaeye网站中获取的包含源的网页（后面没有/）" do
    url = "http://robbin.javaeye.com"
    create_feed(url)
  end

  test "添加rss源---从donews网站中获取的包含源的网页（后面没有/）" do
    url = "http://blog.donews.com/keso"
    create_feed(url)
  end

  test "添加rss源---从donews网站中获取的包含源的网页" do
    clear_model(RssFeed,RssItem)
    url = "http://blog.donews.com/keso/"
    RssFeed.create_rss_feed(url)
    assert_equal RssFeed.count,1
    # 重复创建一下，数量不变
    url = "http://blog.donews.com/keso/"
    RssFeed.create_rss_feed(url)
    assert_equal RssFeed.count,1
  end


  # 创建 '2ch看日本' 的博客rss feed
  test "问题源之一" do
    url = 'http://hi.baidu.com/letus2ch/rss'
    create_feed(url)
  end

  # 增加QQ号码的订阅源
  test "增加QQ号码的订阅源" do
    url = '42817315'
    create_feed(url)
  end

  def create_feed(url)
    clear_model(RssFeed,RssItem)
    RssFeed.create_rss_feed(url)
    assert_equal RssFeed.count,1
  end

end
