require 'test_helper'

class FeedCollectionTest < ActiveSupport::TestCase
  test "创建一个公开的 collection" do
    clear_redis_cache_and_memcache_cache
  end

  test "把 feed 增加到 一个 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = "all-public"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题","我是描述",scope)
    end
    coll = Collection.last

    assert_difference('Feed.count', 1) do
      a.send_feed("我是标题",:detail=>"我是正文",:sendto=>"all-public")
    end
    feed = Feed.last

    assert_difference('FeedCollection.count', 1) do
      coll.add_feed(feed,a)
    end
    assert_equal coll.feeds_db,coll.feeds
    assert_equal [feed],coll.feeds_db
  end

  test "创建一个指定了 collection 的 feed" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = "all-public"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题","我是描述",scope)
    end
    coll = Collection.last

    assert_difference(['Feed.count','FeedCollection.count'], 1) do
      a.send_feed("我是标题",:detail=>"我是正文",:sendto=>"all-public",:collection=>coll)
    end
    feed = Feed.last
    assert_equal coll.feeds_db,coll.feeds
    assert_equal [feed],coll.feeds_db
  end

  test "把 feed 增加到 一个自己不能操作的collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题","我是描述",scope)
    end
    coll = Collection.last

    assert_difference('Feed.count', 1) do
      b.send_feed("我是标题",:detail=>"我是正文",:sendto=>"all-public")
    end
    feed = Feed.last

    assert_difference('FeedCollection.count', 0) do
      coll.add_feed(feed,b)
    end
  end

  test "创建一个指定了 自己不能操作的collection 的feed" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题","我是描述",scope)
    end
    coll = Collection.last

    assert_difference('FeedCollection.count', 0) do
      assert_difference('Feed.count', 1) do
        b.send_feed("我是标题",:detail=>"我是正文",:sendto=>"all-public",:collection=>coll)
      end
    end
  end
end
