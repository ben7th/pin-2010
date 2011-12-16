require 'test_helper'

class InCollectionTest < ActiveSupport::TestCase

  test "自己创建的 collection,可以被自己看到" do
    clear_redis_cache_and_memcache_cache
    lifei = users(:lifei)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      lifei.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    assert_equal lifei.created_collections, lifei.created_collections
    assert_equal [collection], lifei.created_collections
    assert_equal [collection], lifei.in_collections
  end

  test "好友的创建的公开 collection,可以被自己看到" do
    clear_redis_cache_and_memcache_cache
    init_a_followings
    a = users(:a)
    b = users(:b)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      b.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    assert_equal b.out_collections, b.out_collections_db
    assert_equal [collection], a.in_collections

    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    assert_equal [collection], channel_ac.in_collections
    assert_equal [], channel_ad.in_collections
  end

  test "粉丝创建的给所有好友的 collection,可以被自己看到" do
    clear_redis_cache_and_memcache_cache
    init_a_followings
    a = users(:a)
    b = users(:b)
    scope = CollectionScope::FOLLOWINGS
    assert_difference('Collection.count', 1) do
      b.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    assert_equal b.to_followings_out_collections_db,b.to_followings_out_collections
    assert_equal [collection], b.to_followings_out_collections
    assert_equal [collection], a.in_collections

    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    assert_equal [collection], channel_ac.in_collections
    assert_equal [], channel_ad.in_collections
  end

  test "好友创建的给自己的 collection,可以被自己看到" do
    clear_redis_cache_and_memcache_cache
    init_a_followings
    a = users(:a)
    b = users(:b)
    scope = "u-#{a.id}"
    assert_difference('Collection.count', 1) do
      b.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    assert_equal b.to_personal_out_collections_db,b.to_personal_out_collections
    assert_equal [collection],b.to_personal_out_collections
    assert_equal a.to_personal_in_collections_db,a.to_personal_in_collections
    assert_equal [collection],a.to_personal_in_collections
    assert_equal [collection],a.in_collections

    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    assert_equal [collection], channel_ac.in_collections
    assert_equal [], channel_ad.in_collections
  end

  test "好友创建给频道的 collection,并且自己在这个频道,可以被自己看到" do
    clear_redis_cache_and_memcache_cache
    init_a_followings
    a = users(:a)
    b = users(:b)
    channel_bd = channels(:channel_bd)
    scope = "ch-#{channel_bd.id}"
    assert_difference('Collection.count', 1) do
      b.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    assert_equal channel_bd.out_collections_db,channel_bd.out_collections
    assert_equal [collection], channel_bd.out_collections
    assert_equal [collection], a.in_collections

    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    assert_equal [collection], channel_ac.in_collections
    assert_equal [], channel_ad.in_collections

    assert_equal [collection], channel_bd.in_collections
  end

  def init_a_followings
    a = users(:a)
    b = users(:b)
    channel_ac = channels(:channel_ac)
    channel_bd = channels(:channel_bd)
    channel_ac.add_user(b)
    channel_bd.add_user(a)
    assert_equal a.followings_db,a.followings
    assert_equal [b],a.followings
    assert_equal b.followings_db,b.followings
    assert_equal [a],b.followings
  end

end
