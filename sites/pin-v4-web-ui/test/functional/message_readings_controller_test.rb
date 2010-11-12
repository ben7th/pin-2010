require 'test_helper'

class MessageReadingsControllerTest < ActionController::TestCase
  
  test "把一条消息标记为未读" do
    songliang = users(:songliang)
    lifei = users(:lifei)
    assert_difference("Participating.count",2)do
      assert_difference("Message.count",1)do
        Message.create!(:creator=>songliang,:participant_ids=>[lifei.id],:title=>'问好',:content=>'大家好！')
      end
    end
    session[:user_id] = lifei.id
    message = Message.last
    # 标记为未读
    put :mark,:message_ids=>[message.id],:unread=>true,:display_mode=>'in'
    message_reading = message.reading_of(lifei)
    assert_equal message_reading.is_unread?,true
    # 标记为已读
    message_reading.read!
    # 删除
    delete :destroys,:message_ids=>[message.id],:display_mode=>'in'
    message_reading.reload
    assert_equal message_reading.hidden,true
    # 回复一个
    Message.create!(:creator=>songliang,:reply_message=>message,:participant_ids=>[lifei.id],:title=>'回复问好',:content=>'大家都很好，你好啊？')
    message_reading.reload
    assert_equal message_reading.is_unread?,true
    assert_equal message_reading.hidden,false
  end

  test "删除草稿(根消息是草稿)" do
    songliang = users(:songliang)
    lifei = users(:lifei)
    m1,m2,m3 = nil,nil,nil
    assert_difference("Participating.count",6)do
      assert_difference("Message.count",3)do
        m1 = Message.create!(:draft=>true,:creator=>lifei,:participant_ids=>[songliang.id],:title=>'问好',:content=>'大家好！')
        m2 = Message.create!(:draft=>true,:creator=>lifei,:participant_ids=>[songliang.id],:title=>'问好',:content=>'大家好！')
        m3 = Message.create!(:draft=>true,:creator=>lifei,:participant_ids=>[songliang.id],:title=>'问好',:content=>'大家好！')
      end
    end
    session[:user_id] = lifei.id
    assert_difference("Message.count",-3)do
      delete :destroys,:message_ids=>[m1.id,m2.id,m3.id],:display_mode=>'draft'
    end
  end
end
