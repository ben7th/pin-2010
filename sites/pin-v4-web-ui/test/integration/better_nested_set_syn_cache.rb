require 'test_helper'

class BetterNestedSetSynCache < ActionController::IntegrationTest
  fixtures :all

  def clear_tables
    clear_model(Message,MessageModeling,MessageReading)
  end

  def users_to_params_receivers(users)
    receivers = []
    users.each do |user|
      receivers << "#{user.id},#{user.name}"
    end
    return receivers
  end

  test "缓存与数据库的同步测试(Better nested set插件在更新数据的同时要同时更新缓存)" do
    clear_tables

    songliang = users(:songliang)
    lifei = users(:lifei)

    receiver_str_arr = users_to_params_receivers([lifei])

    # 两个消息树 分别是 （lft:1，rgt:2）,（lft:3，rgt:4）
    message_1 = Message.create!(:sender=>songliang,:receiver_str_arr=>receiver_str_arr,:title=>'我是标题',:content=>'大家好！')
    message_2 = Message.create!(:sender=>songliang,:receiver_str_arr=>receiver_str_arr,:title=>'我是标题',:content=>'大家好！')
    assert_equal Message.count,2
    assert_equal message_1.lft,1
    assert_equal message_1.rgt,2
    assert_equal message_2.lft,3
    assert_equal message_2.rgt,4
    # 生成两个消息的缓存
    cache_message_1 = Message.find(message_1.id)
    cache_message_2 = Message.find(message_2.id)
    assert_equal cache_message_1.lft,1
    assert_equal cache_message_1.rgt,2
    assert_equal cache_message_2.lft,3
    assert_equal cache_message_2.rgt,4
    # 在第一颗树下回复一个消息草稿
    message_1_reply_draft = Message.create!(:draft=>true,:reply_to=>message_1.id,:sender=>songliang,:receiver_str_arr=>receiver_str_arr,:title=>'我是标题',:content=>'大家好！')
    assert_equal Message.count,3
    assert_equal message_1_reply_draft.lft,2
    assert_equal message_1_reply_draft.rgt,3
    # 缓存应该和数据库同步
    cache_message_1 = Message.find(message_1.id)
    cache_message_2 = Message.find(message_2.id)
    assert_equal cache_message_1.lft,1
    assert_equal cache_message_1.rgt,4
    assert_equal cache_message_2.lft,5
    assert_equal cache_message_2.rgt,6
    # 删除草稿
    message_1_reply_draft.destroy
    cache_message_1 = Message.find(message_1.id)
    cache_message_2 = Message.find(message_2.id)
    assert_equal cache_message_1.lft,1
    assert_equal cache_message_1.rgt,2
    assert_equal cache_message_2.lft,3
    assert_equal cache_message_2.rgt,4
  end
end
