require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test "创建一个公开的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal a, coll.creator
    assert_equal true, coll.public?
  end

  test "创建一个公开+个人 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    scope = "#{Collection::SendStatus::PUBLIC},u-#{b.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 1, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal true, coll.public?
    assert_equal [b], coll.sent_users
  end

  test "创建一个对所有好友的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = CollectionScope::FOLLOWINGS
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 1, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal true, coll.sent_all_followings?
  end

  test "创建一个对所有好友+个人 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    scope = "#{CollectionScope::FOLLOWINGS},u-#{b.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 2, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal true, coll.sent_all_followings?
    assert_equal [b], coll.sent_users
  end

  test "创建一个 单个频道的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 1, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal [channel_ac], coll.sent_channels
  end

  test "创建一个 单个频道的+个人 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id},u-#{b.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 2, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal [b], coll.sent_users
    assert_equal [channel_ac], coll.sent_channels
  end

  test "创建一个 对个人的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    scope = "u-#{b.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 1, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal [b], coll.sent_users
  end

  test "创建一个 对多人的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    c = users(:c)
    scope = "u-#{b.id},u-#{c.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 2, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal 2, coll.sent_users.count
    assert_equal true, coll.sent_users.include?(b)
    assert_equal true, coll.sent_users.include?(c)
  end

  test "创建一个 多个频道的 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    scope = "ch-#{channel_ac.id},ch-#{channel_ad.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 2, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal 2, coll.sent_channels.count
    assert_equal true, coll.sent_channels.include?(channel_ac)
    assert_equal true, coll.sent_channels.include?(channel_ad)
  end

  test "创建一个 多个频道+个人 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    b = users(:b)
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    scope = "ch-#{channel_ac.id},ch-#{channel_ad.id},u-#{b.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 3, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal 2, coll.sent_channels.count
    assert_equal true, coll.sent_channels.include?(channel_ac)
    assert_equal true, coll.sent_channels.include?(channel_ad)
    assert_equal [b], coll.sent_users
  end

  test "collection 的范围不能包括 非创建者的频道" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    channel_bd = channels(:channel_bd)
    scope = "ch-#{channel_bd.id}"
    assert_difference('Collection.count', 0) do
      a.create_collection_by_params("我是标题",scope)
    end
  end

  test "各种范围格式错误" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)

    error_scope_list = [
      "#{Collection::SendStatus::PRIVATE},#{CollectionScope::FOLLOWINGS}",
      "#{Collection::SendStatus::PRIVATE},ch-#{channel_ac.id}",
      "#{CollectionScope::FOLLOWINGS},ch-#{channel_ac.id}",
      "#{Collection::SendStatus::PUBLIC},abc",
      "aef1"
    ]
    error_scope_list.each do |scope|
      assert_raise(CollectionScope::FormatError) do
        a.create_collection_by_params("我是标题",scope)
      end
    end

    assert_raise(CollectionScope::UnSpecifiedError) do
      a.create_collection_by_params("我是标题", "#{Collection::SendStatus::SCOPED}")
    end
  end


  test "删除 collection" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal 0, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal true, coll.public?
    assert_difference(['Collection.count'], -1) do
      coll.destroy
    end
  end

  test "修改 collection sendto 范围" do
    clear_redis_cache_and_memcache_cache
    a = users(:a)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    coll = Collection.last
    assert_equal a, coll.creator
    assert_equal true, coll.public?

    scope = CollectionScope::FOLLOWINGS
    coll.change_sendto(scope)
    coll = Collection.last
    assert_equal 1, coll.collection_scopes.count
    assert_equal a, coll.creator
    assert_equal false, coll.public?
    assert_equal true, coll.sent_all_followings?
  end

end
