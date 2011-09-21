#1 ABCD 四个人
#    A 被 B C 关注
#    B 被 C D 关注
#    C 被 D A 关注
#    D 被 A B 关注
#2 ABCD 每个人有两个频道
#  A channel_ac,channel_ad
#  B channel_bd,channel_ba
#  C channel_ca,channel_cb
#  D channel_db,channel_dc

require 'test_helper'
class SendFeedTest < ActiveSupport::TestCase
  test '测试环境' do
    init_users_and_contacts
  end

  test "a 发送 私有信息" do
    init_users_and_contacts

    a = users(:a)
    scope = Collection::SendStatus::PRIVATE
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"

    feed = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed.id.blank?
    feed.reload
    # 各种发件箱和自己的收件箱
    assert_equal [feed],a.private_feeds
    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds

    feed_1 = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload
    # 各种发件箱和自己的收件箱
    assert_equal [feed_1,feed],a.private_feeds
    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds
  end

  test "a 发送 公开信息" do
    init_users_and_contacts

    a = users(:a)
    scope = Collection::SendStatus::PUBLIC
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed.id.blank?
    feed.reload
    # 各种发件箱和自己的收件箱
    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [feed],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds
    # 自己的频道
    channel_ac = channels(:channel_ac)
    assert_equal [],channel_ac.out_feeds
    assert_equal [],channel_ac.in_feeds
    channel_ad = channels(:channel_ad)
    assert_equal [],channel_ad.out_feeds
    assert_equal [],channel_ad.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [feed],b.in_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [feed],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [feed],c.in_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [feed],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds
    
    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload
    # 各种发件箱和自己的收件箱
    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [feed_1,feed],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds
    # 自己的频道
    channel_ac = channels(:channel_ac)
    assert_equal [],channel_ac.out_feeds
    assert_equal [],channel_ac.in_feeds
    channel_ad = channels(:channel_ad)
    assert_equal [],channel_ad.out_feeds
    assert_equal [],channel_ad.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [feed_1,feed],b.in_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [feed_1,feed],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [feed_1,feed],c.in_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [feed_1,feed],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds
  end

  test "a 向 channel_ac 发送信息" do
    init_users_and_contacts

    a = users(:a)
    channel_ac = channels(:channel_ac)
    scope ="ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed.id.blank?
    feed.reload
    # 发件箱和自己的收件箱
    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds

    assert_equal [feed],channel_ac.out_feeds
    assert_equal [feed],channel_ac.in_feeds
    channel_ad = channels(:channel_ad)
    assert_equal [],channel_ad.out_feeds
    assert_equal [],channel_ad.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [feed],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [feed],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    assert_equal [],d.incoming_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 是否发送成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload
    # 发件箱和自己的收件箱
    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds
    channel_ac.reload
    assert_equal [feed_1,feed],channel_ac.out_feeds
    assert_equal [feed_1,feed],channel_ac.in_feeds
    channel_ad = channels(:channel_ad)
    assert_equal [],channel_ad.out_feeds
    assert_equal [],channel_ad.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [feed_1,feed],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    assert_equal [],d.incoming_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds
  end

  test "a 向 channel_ad 发送信息" do
    init_users_and_contacts

    a = users(:a)
    channel_ad = channels(:channel_ad)
    scope = "ch-#{channel_ad.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题","我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload
    # 发件箱和自己的收件箱
    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds
    
    assert_equal [feed],channel_ad.out_feeds
    assert_equal [feed],channel_ad.in_feeds
    channel_ac = channels(:channel_ac)
    assert_equal [],channel_ac.out_feeds
    assert_equal [],channel_ac.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    assert_equal [feed],d.incoming_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    channel_ad.reload

    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload
    # 发件箱和自己的收件箱
    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds

    assert_equal [feed_1,feed],channel_ad.out_feeds
    assert_equal [feed_1,feed],channel_ad.in_feeds
    channel_ac = channels(:channel_ac)
    assert_equal [],channel_ac.out_feeds
    assert_equal [],channel_ac.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [],channel_ba.in_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds
  end

  test "a 向 channel_ac 发送信息，再把 c 从频道移除" do
    init_users_and_contacts

    a = users(:a)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"

    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [feed],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [feed],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds

    channel_ac.remove_user(c)
    channel_ac.reload
    assert_equal [],channel_ac.include_users
    assert_equal [],channel_ac.include_users_db

    c = users(:c)
    assert_equal [],c.out_feeds
    assert_equal [],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [],channel_ca.out_feeds
    assert_equal [],channel_ca.in_feeds
    channel_cb = channels(:channel_cb)
    assert_equal [],channel_cb.out_feeds
    assert_equal [],channel_cb.in_feeds
  end

  test "a 向 channel_ac 发送信息，再把 d 增加到频道，再把 b 增加到频道" do
    init_users_and_contacts

    a = users(:a)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [],a.to_followings_out_feeds

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [],b.in_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [],channel_ba.in_feeds

    channel_ac.add_user(d)
    channel_ac.reload
    assert_equal true,channel_ac.include_users.include?(d)
    assert_equal true,channel_ac.include_users_db.include?(d)
    channel_ac.add_user(b)
    channel_ac.reload
    assert_equal true,channel_ac.include_users.include?(b)
    assert_equal true,channel_ac.include_users_db.include?(b)

    d = users(:d)
    assert_equal [],d.out_feeds
    assert_equal [],d.in_feeds
    assert_equal [feed],d.incoming_feeds
    channel_db = channels(:channel_db)
    assert_equal [],channel_db.out_feeds
    assert_equal [],channel_db.in_feeds
    channel_dc = channels(:channel_dc)
    assert_equal [],channel_dc.out_feeds
    assert_equal [],channel_dc.in_feeds

    b = users(:b)
    assert_equal [],b.out_feeds
    assert_equal [feed],b.in_feeds
    assert_equal [],b.incoming_feeds
    channel_bd = channels(:channel_bd)
    assert_equal [],channel_bd.out_feeds
    assert_equal [],channel_bd.in_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [],channel_ba.out_feeds
    assert_equal [feed],channel_ba.in_feeds
  end

  test "a 发送给所有好友信息" do
    init_users_and_contacts

    a = users(:a)
    scope = CollectionScope::FOLLOWINGS
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload
    # 发件箱 和 自己的收件箱
    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_followings_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    c = users(:c)
    assert_equal [feed],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    d = users(:d)
    assert_equal [],d.in_feeds
    assert_equal [feed],d.incoming_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_followings_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.incoming_feeds
    c = users(:c)
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    d = users(:d)
    assert_equal [],d.in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "a 发送给 d 信息" do
    init_users_and_contacts

    a = users(:a)
    d = users(:d)
    scope = "u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"

    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    assert_equal false, feed.id.blank?

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    c = users(:c)
    assert_equal [],c.in_feeds
    assert_equal [],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    assert_equal false, feed_1.id.blank?

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    c = users(:c)
    assert_equal [],c.in_feeds
    assert_equal [],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds

    channel_db = channels(:channel_db)
    channel_db.add_user(a)
    d.reload
    channel_db.reload
    assert_equal [feed_1,feed],d.in_feeds
    assert_equal [feed_1,feed],d.to_personal_in_feeds
    assert_equal [],d.incoming_to_personal_in_feeds
    assert_equal [],d.incoming_feeds
    assert_equal [feed_1,feed],channel_db.in_feeds
    channel_db.remove_user(a)
    d.reload
    channel_db.reload
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
    assert_equal [],channel_db.in_feeds
  end

  test "a 发送给 c 信息" do
    init_users_and_contacts

    a = users(:a)
    c = users(:c)
    scope = "u-#{c.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"

    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    assert_equal false, feed.id.blank?

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    d = users(:d)
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [],d.incoming_to_personal_in_feeds
    assert_equal [],d.incoming_feeds
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds

    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    assert_equal false, feed_1.id.blank?

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds

    b = users(:b)
    assert_equal [],b.in_feeds
    assert_equal [],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    d = users(:d)
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [],d.incoming_to_personal_in_feeds
    assert_equal [],d.incoming_feeds
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds

    channel_ca.remove_user(a)
    channel_ca.reload
    assert_equal [],c.in_feeds
    assert_equal [],c.to_personal_in_feeds
    assert_equal [feed_1,feed],c.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],c.incoming_feeds
    assert_equal [],channel_ca.in_feeds
    channel_ca.add_user(a)
    c.reload
    channel_ca.reload
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    assert_equal [feed_1,feed],channel_ca.in_feeds
  end

  test "a 发送主题，范围（b,c,d）" do
    init_users_and_contacts

    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    scope = "u-#{b.id},u-#{c.id},u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"

    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds
    #b
    assert_equal [feed],b.in_feeds
    assert_equal [feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed],channel_ba.in_feeds
    #c
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds
    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds
    #b
    assert_equal [feed_1,feed],b.in_feeds
    assert_equal [feed_1,feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed_1,feed],channel_ba.in_feeds
    #c
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "a 发送主题，范围 （公开,b,c,d）" do
    init_users_and_contacts

    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    scope = "#{Collection::SendStatus::PUBLIC},u-#{b.id},u-#{c.id},u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [feed],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds
    #b
    assert_equal [feed],b.in_feeds
    assert_equal [feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed],channel_ba.in_feeds
    #c
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds
    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed.reload

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [feed_1,feed],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds
    #b
    assert_equal [feed_1,feed],b.in_feeds
    assert_equal [feed_1,feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed_1,feed],channel_ba.in_feeds
    #c
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "a 发送主题，范围 （好友,b,c,d）" do
    init_users_and_contacts

    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    scope = "#{CollectionScope::FOLLOWINGS},u-#{b.id},u-#{c.id},u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds
    assert_equal [feed],a.to_followings_out_feeds
    #b
    assert_equal [feed],b.in_feeds
    assert_equal [feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed],channel_ba.in_feeds
    #c
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds
    a.reload
    b.reload
    c.reload
    d.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds
    assert_equal [feed_1,feed],a.to_followings_out_feeds
    #b
    assert_equal [feed_1,feed],b.in_feeds
    assert_equal [feed_1,feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed_1,feed],channel_ba.in_feeds
    #c
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "a 发送主题，范围 （channel_ac,b,c,d）" do
    init_users_and_contacts

    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    channel_ac = channels(:channel_ac)
    scope = "ch-#{channel_ac.id},u-#{b.id},u-#{c.id},u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds
    assert_equal [feed],channel_ac.out_feeds
    #b
    assert_equal [feed],b.in_feeds
    assert_equal [feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed],channel_ba.in_feeds
    #c
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds
    a.reload
    b.reload
    c.reload
    d.reload
    channel_ac.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds
    assert_equal [feed_1,feed],channel_ac.out_feeds
    #b
    assert_equal [feed_1,feed],b.in_feeds
    assert_equal [feed_1,feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed_1,feed],channel_ba.in_feeds
    #c
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "a 发送主题，范围 （channel_ad,b,c,d）" do
    init_users_and_contacts

    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    channel_ad = channels(:channel_ad)
    scope = "ch-#{channel_ad.id},u-#{b.id},u-#{c.id},u-#{d.id}"
    assert_difference('Collection.count', 1) do
      a.create_collection_by_params("我是标题",scope)
    end
    collection = Collection.last
    collection_ids = "#{collection.id}"
    feed = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed.id.blank?
    feed.reload

    assert_equal [feed],a.sent_feeds_db
    assert_equal [feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed],a.in_feeds
    assert_equal [feed],a.to_personal_out_feeds
    assert_equal [feed],channel_ad.out_feeds
    #b
    assert_equal [feed],b.in_feeds
    assert_equal [feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed],channel_ba.in_feeds
    #c
    assert_equal [feed],c.in_feeds
    assert_equal [feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed],d.incoming_to_personal_in_feeds
    assert_equal [feed],d.incoming_feeds
    a.reload
    b.reload
    c.reload
    d.reload
    channel_ad.reload
    feed_1 = a.send_feed("我是标题", "我是正文",:collection_ids=>collection_ids)
    # 发送是否成功
    assert_equal false, feed_1.id.blank?
    feed_1.reload

    assert_equal [feed_1,feed],a.sent_feeds_db
    assert_equal [feed_1,feed],a.sent_feeds
    assert_equal [],a.out_feeds
    assert_equal [feed_1,feed],a.in_feeds
    assert_equal [feed_1,feed],a.to_personal_out_feeds
    assert_equal [feed_1,feed],channel_ad.out_feeds
    #b
    assert_equal [feed_1,feed],b.in_feeds
    assert_equal [feed_1,feed],b.to_personal_in_feeds
    assert_equal [],b.incoming_to_personal_in_feeds
    assert_equal [],b.incoming_feeds
    channel_ba = channels(:channel_ba)
    assert_equal [feed_1,feed],channel_ba.in_feeds
    #c
    assert_equal [feed_1,feed],c.in_feeds
    assert_equal [feed_1,feed],c.to_personal_in_feeds
    assert_equal [],c.incoming_to_personal_in_feeds
    assert_equal [],c.incoming_feeds
    channel_ca = channels(:channel_ca)
    assert_equal [feed_1,feed],channel_ca.in_feeds
    #d
    assert_equal [],d.in_feeds
    assert_equal [],d.to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_to_personal_in_feeds
    assert_equal [feed_1,feed],d.incoming_feeds
  end

  test "各种发送范围不正确" do
    init_users_and_contacts
    a = users(:a)

    assert_raise(RuntimeError) do
      a.send_feed("我是标题", "我是正文")
    end
  end

  def init_users_and_contacts
    # 清空 redis 缓存
    RedisCache.instance.flushdb
    # 清空 memcache Cash::Mock
    $memcache.flush_all
    a = users(:a)
    b = users(:b)
    c = users(:c)
    d = users(:d)
    
    #  A channel_ac,channel_ad
    channel_ac = channels(:channel_ac)
    channel_ad = channels(:channel_ad)
    channels_a = a.channels
    assert_equal 2,channels_a.count
    assert_equal true,channels_a.include?(channel_ac)
    assert_equal true,channels_a.include?(channel_ad)
    channel_ac.add_user(c)
    assert_equal [c], channel_ac.include_users_db
    assert_equal [c], channel_ac.include_users
    channel_ad.add_user(d)
    assert_equal [d], channel_ad.include_users_db
    assert_equal [d], channel_ad.include_users
    #  B channel_bd,channel_ba
    channel_bd = channels(:channel_bd)
    channel_ba = channels(:channel_ba)
    channels_b = b.channels
    assert_equal 2,channels_b.count
    assert_equal true,channels_b.include?(channel_bd)
    assert_equal true,channels_b.include?(channel_ba)
    channel_bd.add_user(d)
    assert_equal [d], channel_bd.include_users_db
    assert_equal [d], channel_bd.include_users
    channel_ba.add_user(a)
    assert_equal [a], channel_ba.include_users_db
    assert_equal [a], channel_ba.include_users

    #  C channel_ca,channel_cb
    channel_ca = channels(:channel_ca)
    channel_cb = channels(:channel_cb)
    channels_c = c.channels
    assert_equal 2,channels_c.count
    assert_equal true,channels_c.include?(channel_ca)
    assert_equal true,channels_c.include?(channel_cb)
    channel_ca.add_user(a)
    assert_equal [a], channel_ca.include_users_db
    assert_equal [a], channel_ca.include_users
    channel_cb.add_user(b)
    assert_equal [b], channel_cb.include_users_db
    assert_equal [b], channel_cb.include_users

    #  D channel_db,channel_dc
    channel_db = channels(:channel_db)
    channel_dc = channels(:channel_dc)
    channels_d = d.channels
    assert_equal 2, channels_d.count
    assert_equal true,channels_d.include?(channel_db)
    assert_equal true,channels_d.include?(channel_dc)
    channel_db.add_user(b)
    assert_equal [b], channel_db.include_users_db
    assert_equal [b], channel_db.include_users
    channel_dc.add_user(c)
    assert_equal [c], channel_dc.include_users_db
    assert_equal [c], channel_dc.include_users

    #    a 被 b c 关注
    #    b 被 c d 关注
    #    c 被 d a 关注
    #    d 被 a b 关注
    # 验证 a 的关系
    followings_a = a.followings
    assert_equal 2,followings_a.count
    assert_equal true,followings_a.include?(c)
    assert_equal true,followings_a.include?(d)
    fans_a = a.fans
    assert_equal 2,fans_a.count
    assert_equal true,fans_a.include?(b)
    assert_equal true,fans_a.include?(c)

    assert_equal [c],a.mutual_followings

    # 验证 b 的关系
    followings_b = b.followings
    assert_equal 2,followings_b.count
    assert_equal true,followings_b.include?(a)
    assert_equal true,followings_b.include?(d)
    fans_b = b.fans
    assert_equal 2,fans_b.count
    assert_equal true,fans_b.include?(c)
    assert_equal true,fans_b.include?(d)

    assert_equal [d],b.mutual_followings

    # 验证 c 的关系
    followings_c = c.followings
    assert_equal 2,followings_c.count
    assert_equal true,followings_c.include?(a)
    assert_equal true,followings_c.include?(b)
    fans_c = c.fans
    assert_equal 2,fans_c.count
    assert_equal true,fans_c.include?(d)
    assert_equal true,fans_c.include?(a)

    assert_equal [a],c.mutual_followings

    # 验证 d 的关系
    followings_d = d.followings
    assert_equal 2,followings_d.count
    assert_equal true,followings_d.include?(b)
    assert_equal true,followings_d.include?(c)
    fans_d = d.fans
    assert_equal 2,fans_d.count
    assert_equal true,fans_d.include?(a)
    assert_equal true,fans_d.include?(b)

    assert_equal [b],d.mutual_followings
  end

end



