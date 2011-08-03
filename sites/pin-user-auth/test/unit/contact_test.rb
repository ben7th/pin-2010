require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "followings 测试" do
    # 清空 redis 缓存
    RedisCache.instance.flushdb
    # 清空 memcache Cash::Mock
    $memcache.flush_all
    a = users(:a)
    assert_equal a.followings,a.followings_db
    assert_equal [],a.followings_db
    zhang = users(:zhang)
    wang = users(:wang)
    zhao = users(:zhao)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    channel_ac.add_user(b)
    channel_ac.add_user(zhao)
    channel_ac.add_user(c)
    channel_ac.add_user(d)
    channel_ad.add_user(zhao)
    assert_equal a.followings_db,a.followings
    assert_equal [d,c,zhao,b],a.followings
    channel_ad.add_user(wang)
    assert_equal a.followings_db,a.followings
    assert_equal [wang,d,c,zhao,b],a.followings
    channel_ad.add_user(b)
    assert_equal a.followings_db,a.followings
    assert_equal [wang,d,c,zhao,b],a.followings
    channel_ad.add_user(zhang)
    assert_equal a.followings_db,a.followings
    assert_equal [zhang,wang,d,c,zhao,b],a.followings

    assert_equal zhao.fans_db,zhao.fans_db
    assert_equal [a],zhao.fans
    channel_ad.remove_user(zhao)
    assert_equal a.followings_db,a.followings
    assert_equal [zhang,wang,d,c,zhao,b],a.followings
    assert_equal zhao.fans_db,zhao.fans_db
    assert_equal [a],zhao.fans
    channel_ac.remove_user(zhao)
    assert_equal a.followings_db,a.followings
    assert_equal [zhang,wang,d,c,b],a.followings
    assert_equal zhao.fans_db,zhao.fans_db
    assert_equal [],zhao.fans
  end

  test "fans 测试" do
    # 清空 redis 缓存
    RedisCache.instance.flushdb
    # 清空 memcache Cash::Mock
    $memcache.flush_all
    zhang = users(:zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [],zhang.fans_db
    a = users(:a)
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    b = users(:b)
    channel_bd = channels(:channel_bd)
    channel_ba = channels(:channel_ba)
    c = users(:c)
    channel_ca = channels(:channel_ca)
    
    channel_ac.add_user(zhang)
    channel_bd.add_user(zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [b,a],zhang.fans_db
    channel_ca.add_user(zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [c,b,a],zhang.fans_db
    channel_ba.add_user(zhang)
    channel_ad.add_user(zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [c,b,a],zhang.fans_db

    channel_ba.remove_user(zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [c,b,a],zhang.fans_db
    channel_bd.remove_user(zhang)
    assert_equal zhang.fans,zhang.fans_db
    assert_equal [c,a],zhang.fans_db
  end
end
