require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def clear_tables
    # 清空message相关数据表
    clear_model(MessageReading,Message,Participating)
    assert_equal MessageReading.count , 0
    assert_equal Message.count , 0
    assert_equal Participating.count , 0
  end

  def sendmessage_on_participants
    songliang = users(:songliang)

    # 宋亮发送消息，没有参与者
    assert_difference('Message.count',1)do
      Message.create!(:creator=>songliang,:title=>'我是标题',:content=>'大家好！')
    end
    # 产生了一个新话题
    message = Message.last
    assert_equal message.descendants.count,0
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'我是标题'
    assert_equal message.content,'大家好！'

    assert_equal message.participatings.count,1
    assert_equal message.participants.count,1
    assert_equal message.creator,songliang
    assert message.participants.include?(songliang)
  end

  def sendmessage_no_self
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    entry = entries(:entry_file_2)
    # 宋亮发送消息给李飞、程立文
    assert_difference('Message.count',1)do
      message = Message.new(:creator=>songliang,:entry_ids=>[entry.id],:participant_ids=>[lifei.id,chengliwen.id],:title=>'我是标题',:content=>'大家好！')
      message.save
    end
    # 产生了一个新话题
    message = Message.last
    assert_equal message.descendants.count,0
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'我是标题'
    assert_equal message.content,'大家好！'
    assert_equal message.entries.type_of(FileEntry).count,1

    assert_equal message.participatings.count,3
    assert_equal message.participants.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(songliang)
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
  end

  def sendmessage_include_self
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)

    # 宋亮发送消息给李飞、程立文,宋亮
    assert_difference('Message.count',1)do
      Message.create!(:creator=>songliang,:participant_ids=>[lifei.id,chengliwen.id,songliang.id],:title=>'我是标题',:content=>'大家好！')
    end
    # 产生了一个新消息
    message = Message.last
    # 这个话题还没有回复
    assert_equal message.descendants.count,0
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'我是标题'
    assert_equal message.content,'大家好！'
    
    assert_equal message.participatings.count,3
    assert_equal message.participants.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(songliang)
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)

  end

  def save_draft_message
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)

    # 宋亮发送消息给李飞、程立文,宋亮
    assert_difference('Message.count',1)do
      Message.create!(:draft=>true,:creator=>songliang,:participant_ids=>[lifei.id,chengliwen.id,songliang.id],:title=>'我是标题',:content=>'大家好！')
    end
    message = Message.last
    assert_equal message.draft,true
  end

  test '发起消息话题（收件人不包括自己）' do
    sendmessage_no_self
  end

  test '发起消息话题（收件人包括自己）' do
    sendmessage_include_self
  end

  test "发起消息话题（没有指定参与者）" do
    sendmessage_on_participants
  end

  test "收件箱的顺序测试(回复不指定参与者)" do
    sendmessage_on_participants
    message_1 = Message.last
    sleep 1
    sendmessage_include_self
    message_2 = Message.last
    songliang = users(:songliang)
    # 按照晚发送的信息排在前面的规则，顺序是 message_2,message_1
    assert_equal songliang.inbox_messages,[message_2,message_1]
    # 回复 message_1,不指定参与者
    sleep 1
    assert_difference("Message.count",1) do
      message = Message.create!(:reply_to=>message_1,:draft=>false,:creator=>songliang,:title=>'我是标题',:content=>'大家好！')
      assert_equal message.parent,message_1
    end
    # 因为 message_1 被回复了，所以收件箱中 message_1 应该在最前面
    songliang.reload
    assert_equal songliang.inbox_messages,[message_1,message_2]
  end
  
  test "收件箱的顺序测试(回复指定参与者)" do
    sendmessage_on_participants
    message_1 = Message.last
    sleep 1
    sendmessage_include_self
    message_2 = Message.last
    songliang = users(:songliang)
    # 按照晚发送的信息排在前面的规则，顺序是 message_2,message_1
    assert_equal songliang.inbox_messages,[message_2,message_1]
    # 回复 message_1,指定参与者
    sleep 1
    lifei = users(:lifei)
    assert_difference("Message.count",1) do
      message = Message.create!(:participant_ids=>[lifei.id],:reply_to=>message_1,:draft=>false,:creator=>songliang,:title=>'我是标题',:content=>'大家好！')
      assert_equal message.parent,message_1
    end
    # 因为 message_1 被回复了，所以收件箱中 message_1 应该在最前面
    songliang.reload
    assert_equal songliang.inbox_messages,[message_1,message_2]
  end


  def method_cache_test(method_name)

  end

  test "message.logic_participants方法的缓存清理测试" do
    method_cache_test("logic_participants")
  end

  test "message.attachment_state 方法的缓存清理测试" do
    method_cache_test("attachment_state")
  end
end
