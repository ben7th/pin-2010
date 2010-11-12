require 'test_helper'
require 'uuidtools'

class MessagesControllerTest < ActionController::TestCase

  def clear_tables
    clear_model(Message,MessageModeling,MessageReading)
  end

  # 发起话题（收件人不包括自己）
  def send_message_no_self
    clear_tables
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    entry = entries(:entry_file_3)
    Entry.expire_caches entry # 清一下缓存，这里写得不好，以后改
    entry = entries(:entry_file_3)
    session[:user_id] = songliang.id
    get 'new'
    assert_response :success
    uuid = UUID.random_create.to_s
    assert_difference('Message.count',1) do
      post 'create',:entry_ids=>[entry.id],:message=>{:title=>'高兴',:content=>'哈哈哈哈哈！',:participant_ids=>[lifei.id,chengliwen.id],:uuid=>uuid}
    end
    # 产生了一个新消息
    message = Message.last
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'高兴'
    assert_equal message.content,'哈哈哈哈哈！'
    assert_equal message.entries.type_of(FileEntry).count,1
    assert_equal message.namespace,'site_mail'
    assert_equal message.uuid,uuid
    assert_equal message.draft?,false

    assert_equal message.participatings.count,3
    assert_equal message.participants.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(songliang)
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end

  # 发起话题（收件人包括自己）
  def send_message_include_self
    clear_tables
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    session[:user_id] = songliang.id
    uuid = UUID.random_create.to_s
    assert_difference('Message.count',1) do
      post 'create',:message=>{:title=>'高兴',:content=>'哈哈哈哈哈！',:participant_ids=>[lifei.id,chengliwen.id,songliang.id],:uuid=>uuid}
    end
    # 产生了一个新消息
    message = Message.last

    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'高兴'
    assert_equal message.content,'哈哈哈哈哈！'
    assert_equal message.namespace,'site_mail'
    assert_equal message.uuid,uuid
    assert_equal message.draft?,false

    assert_equal message.participants.count,3
    assert_equal message.participatings.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
    assert message.participants.include?(songliang)
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end

  def save_draft_when_send_message_no_self
    clear_tables
    lifei = users(:lifei)
    chengliwen,songliang = users(:chengliwen),users(:songliang)
    entry = entries(:entry_file_1)
    session[:user_id] = songliang.id
    uuid = UUID.random_create.to_s
    # message 的发件人是 songliang 收件人是 lifei chengliwen
    assert_difference('Message.count',1) do
      post 'create',:entry_ids=>[entry.id],:message=>{:draft=>true,:title=>'草稿哦',:content=>'仅仅是一个草稿而已！',:participant_ids=>[lifei.id,chengliwen.id],:uuid=>uuid}
    end
    message = Message.last
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'草稿哦'
    assert_equal message.content,'仅仅是一个草稿而已！'
    assert_equal message.namespace,'site_mail'
    assert_equal message.uuid,uuid
    assert_equal message.draft,true

    assert_equal message.participants.count,3
    assert_equal message.participatings.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
    assert message.participants.include?(songliang)
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end

  def save_draft_when_send_message_include_self
    clear_tables
    lifei = users(:lifei)
    chengliwen,songliang = users(:chengliwen),users(:songliang)
    entry = entries(:entry_file_1)
    session[:user_id] = songliang.id
    uuid = UUID.random_create.to_s
    # message 的发件人是 songliang 收件人是 lifei chengliwen songliang
    assert_difference('Message.count',1) do
      post 'create',:entry_ids=>[entry.id],:message=>{:draft=>true,:title=>'草稿哦',:content=>'仅仅是一个草稿而已！',:participant_ids=>[lifei.id,chengliwen.id,songliang.id],:uuid=>uuid}
    end
    message = Message.last
    assert_equal message.parent,nil
    assert_equal message.reply_message,nil

    assert_equal message.title,'草稿哦'
    assert_equal message.content,'仅仅是一个草稿而已！'
    assert_equal message.namespace,'site_mail'
    assert_equal message.uuid,uuid
    assert_equal message.draft,true

    assert_equal message.participants.count,3
    assert_equal message.participatings.count,3
    assert_equal message.creator,songliang
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
    assert message.participants.include?(songliang)
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end

  test "发起话题（收件人不包括自己）" do
    send_message_no_self
  end
  
  test "发起话题（收件人包括自己）" do
    send_message_include_self
  end

  test "发起话题时（收件人不包括自己）保存成草稿" do
    save_draft_when_send_message_no_self
  end

  test "发起话题时（收件人包括自己）保存成草稿" do
    save_draft_when_send_message_include_self
  end

  test "发起话题时保存成草稿,然后再次修改这个草稿" do
    save_draft_when_send_message_include_self
    songliang,lifei = users(:songliang),users(:lifei)
    entry = entries(:entry_file_1)
    uuid = Message.last.uuid
    assert_difference('Message.count',0) do
      post 'create',:entry_ids=>[entry.id],:message=>{:draft=>true,:title=>'草稿哦，再次修改',:content=>'仅仅是一个草稿而已！，再次修改',:participant_ids=>[lifei.id],:uuid=>uuid}
    end
    message = Message.last

    assert_equal message.title,'草稿哦，再次修改'
    assert_equal message.content,'仅仅是一个草稿而已！，再次修改'
    assert_equal message.entries.type_of(FileEntry).count,1
    assert_equal message.draft,true
    assert_equal message.participants.count,2
    assert_equal message.participatings.count,2
    assert_equal message.logic_participants.count,2
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
  end

  test "发起话题时保存成草稿,然后发送出去" do
    save_draft_when_send_message_include_self
    songliang,lifei = users(:songliang),users(:lifei)
    entry = entries(:entry_file_1)
    Entry.expire_caches entry # 清一下缓存，这里写得不好，以后改
    entry = entries(:entry_file_1)
    uuid = Message.last.uuid
    assert_difference('Message.count',0) do
      post 'create',:entry_ids=>[entry.id],
        :message=>{
          :title=>'草稿哦，发送了',
          :content=>'仅仅是一个草稿而已！，发送了',
          :participant_ids=>[lifei.id],
          :uuid=>uuid
        }
    end
    message = Message.last

    assert_equal message.title,'草稿哦，发送了'
    assert_equal message.content,'仅仅是一个草稿而已！，发送了'
    assert_equal message.entries.type_of(FileEntry).count,1
    assert_equal message.draft?,false
    assert_equal message.participants.count,2
    assert_equal message.participatings.count,2
    assert_equal message.logic_participants.count,2
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
  end

  test "发起话题时保存成草稿,然后取消这个草稿" do
    save_draft_when_send_message_include_self
    message = Message.last
    assert_difference('Message.count',-1) do
      assert_difference('Participating.count',-3) do
        delete 'destroy',:id=>message.uuid
      end
    end
  end

  test "回复一个消息，指定参与者" do
    send_message_no_self
    songliang = users(:songliang)
    lifei = users(:lifei)
    chengliwen = users(:chengliwen)
    entry = entries(:entry_file_2)
    Entry.expire_caches entry # 清一下缓存，这里写得不好，以后改
    entry = entries(:entry_file_2)
    reply_message = Message.last

    get "new",:reply_to=>reply_message.id
    assert_response :success

    uuid = UUID.random_create.to_s
    assert_difference('Message.count',1) do
      post 'create',:entry_ids=>[entry.id],:message=>{:reply_to=>reply_message.id,:title=>'回复高兴',:content=>'我回！',:participant_ids=>[lifei.id,chengliwen.id],:uuid=>uuid}
    end
    reply_message.reload
    # 产生了一个新消息
    message = Message.last
    # 这个话题有两个消息
    assert_equal message.parent,reply_message
    assert_equal message.reply_message,reply_message
    assert_equal reply_message.descendants.count,1

    assert_equal message.title,'回复高兴'
    assert_equal message.content,'我回！'
    assert_equal message.entries.type_of(FileEntry).count,1
    assert_equal message.draft?,false
    
    assert_equal message.creator,songliang
    assert_equal message.participatings.count,3
    assert_equal message.participants.count,3
    assert message.participants.include?(lifei)
    assert message.participants.include?(chengliwen)
    assert message.participants.include?(songliang)
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end

  test "回复一个消息，不指定参与者" do
    send_message_no_self
    songliang,lifei,chengliwen = users(:songliang),users(:lifei),users(:chengliwen)
    entry = entries(:entry_file_2)
    reply_message = Message.last

    get "new",:message=>{:reply_to=>reply_message.id}
    assert_response :success

    uuid = UUID.random_create.to_s
    assert_difference('Message.count',1) do
      post 'create',:entry_ids=>[entry.id],:message=>{:reply_to=>reply_message.id,:title=>'回复高兴',:content=>'我回！',:uuid=>uuid}
    end
    reply_message.reload
    # 产生了一个新消息
    message = Message.last
    # 这个话题有两个消息
    assert_equal message.parent,reply_message
    assert_equal message.reply_message,reply_message
    assert_equal reply_message.descendants.count,1

    assert_equal message.title,'回复高兴'
    assert_equal message.content,'我回！'
    assert_equal message.entries.type_of(FileEntry).count,1
    assert_equal message.draft?,false

    assert_equal message.creator,songliang
    assert_equal message.participatings.count,0
    assert_equal message.participants.count,0
    assert_equal message.logic_participants.count,3
    assert message.logic_participants.include?(lifei)
    assert message.logic_participants.include?(songliang)
    assert message.logic_participants.include?(chengliwen)
  end
  
  #
  #  # 回复的时候得到一个草稿信息
  #  def get_a_reply_draft_message
  #    lifei = users(:lifei)
  #    chengliwen = users(:chengliwen)
  #    songliang = users(:songliang)
  #    hanmeimei = users(:hanmeimei)
  #    receiver_str_arr = users_to_params_receivers([lifei,chengliwen,hanmeimei])
  #    entry = resource_entries(:entry_file_1)
  #    send_message_no_self
  #
  #    reply_message = Message.last
  #    assert_equal [1,3], [Message.count,MessageReading.count]
  #
  #    uuid = UUID.random_create.to_s
  #    # message 的发件人是 songliang 收件人是 lifei chengliwen
  #    post 'create',:namespace=>'site_mail',:resource_entry_ids=>[entry.id],:message=>{:draft=>true,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    draft_message = Message.last
  #    assert draft_message.draft?
  #    assert_equal draft_message.reply_to,reply_message.id
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,3
  #    reply_message.reload
  #    assert_equal reply_message.draft_messages_of(songliang).count,1
  #    songliang.reload
  #    assert_equal songliang.draft_root_messages.count,1
  #    get 'index',:display_mode=>'draftbox'
  #    assert_response :success
  #    return [draft_message,reply_message,receiver_str_arr]
  #  end
  #
  #  test "回复消息的时候，将这个回覆的消息保存为草稿,然后发送" do
  #    entry = resource_entries(:entry_file_1)
  #    draft_message,reply_message,receiver_str_arr = get_a_reply_draft_message
  #    post :create,:namespace=>'site_mail',:resource_entry_ids=>[entry.id],:message=>{:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>draft_message.uuid}
  #    assert !draft_message.reload.draft?
  #    # 发送之后，数据库中仅仅是message的draft变成了false，其他的不变化
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,4
  #  end
  #
  #  test "回复消息的时候，将这个回复的消息保存为草稿，然后删除" do
  #    entry = resource_entries(:entry_file_1)
  #    draft_message,reply_message,receivers_parms = get_a_reply_draft_message
  #    post :cancel_create,:resource_entry_ids=>[entry.id],:message=>{:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receivers=>receivers_parms,:uuid=>draft_message.uuid}
  #    assert_equal Message.count,1
  #    assert_equal MessageReading.count,3
  #
  #    # 2010年3月16日 BUG补充测试
  #    # 删除reply_message 回复草稿 的时候，本身的左右值在缓存中没有更新
  #    message = Message.find(reply_message.id)
  #    assert_equal message.rgt, reply_message.reload.rgt
  #    assert_equal message.lft, reply_message.reload.lft
  #  end
  #
  #
  #  test "回复消息的时候创建一个草稿，收件人包含自己,然后发送" do
  #    clear_tables
  #    songliang,lifei,chengliwen = users(:songliang),users(:lifei),users(:chengliwen)
  #    session[:user_id] = songliang.id
  #    receiver_str_arr = users_to_params_receivers([songliang,lifei])
  #    post 'create',:namespace=>'site_mail',:message=>{:draft=>false,:title=>'给自己的一封信',:content=>'仅仅是一封信而已！',:receiver_str_arr=>receiver_str_arr}
  #    assert_equal Message.count,1
  #    assert_equal MessageReading.count,2
  #    reply_message = Message.last
  #
  #    uuid = UUID.random_create.to_s
  #    # 回复给三个人的草稿
  #    receiver_str_arr = users_to_params_receivers([songliang,lifei,chengliwen])
  #    post 'create',:namespace=>'site_mail',:message=>{:draft=>true,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,2
  #
  #    mr_songliang = reply_message.reading_of(songliang)
  #    assert_equal mr_songliang.hidden,false
  #    assert_equal mr_songliang.unread,false
  #    assert_equal mr_songliang.unread_count,0
  #
  #    mr_lifei = reply_message.reading_of(lifei)
  #    assert_equal mr_lifei.hidden,false
  #    assert_equal mr_lifei.unread,true
  #    assert_equal mr_lifei.unread_count,1
  #
  #    message = Message.last
  #    # 发送草稿
  #    post 'create',:namespace=>'site_mail',:message=>{:draft=>false,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,3
  #
  #    mr_songliang = reply_message.reading_of(songliang)
  #    assert_equal mr_songliang.hidden,false
  #    assert_equal mr_songliang.unread,true
  #    assert_equal mr_songliang.unread_count,1
  #
  #    mr_lifei = reply_message.reading_of(lifei)
  #    assert_equal mr_lifei.hidden,false
  #    assert_equal mr_lifei.unread,true
  #    assert_equal mr_lifei.unread_count,2
  #
  #    mr_chengliwen = reply_message.reading_of(chengliwen)
  #    assert_equal mr_chengliwen.hidden,false
  #    assert_equal mr_chengliwen.unread,true
  #    assert_equal mr_chengliwen.unread_count,1
  #  end
  #
  #  test "回复时，连续保存操作草稿信息，新建之后的保存应该更新这个草稿信息" do
  #    lifei = users(:lifei)
  #    chengliwen,hanmeimei = users(:chengliwen),users(:hanmeimei)
  #    receiver_str_arr = users_to_params_receivers([lifei,chengliwen,hanmeimei])
  #    entry = resource_entries(:entry_file_1)
  #    send_message_no_self
  #
  #    reply_message = Message.last
  #    assert_equal [1,3], [Message.count,MessageReading.count]
  #
  #    uuid = UUID.random_create.to_s
  #    # message 的发件人是 songliang 收件人是 lifei chengliwen
  #    post 'create',:namespace=>'site_mail',:resource_entry_ids=>[entry.id],:message=>{:draft=>true,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    draft_message = Message.last
  #    assert draft_message.draft?
  #    assert_equal draft_message.reply_to,reply_message.id
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,3
  #    assert_equal draft_message.content,'我回！但是不发送'
  #    post 'create',:namespace=>'site_mail',:resource_entry_ids=>[entry.id],:message=>{:draft=>true,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送.中国人民是中国人民',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,3
  #    assert_equal draft_message.reload.content,'我回！但是不发送.中国人民是中国人民'
  #    assert_equal draft_message.reply_to,reply_message.id
  #  end
  #
  #  test "回复时，连续保存操作草稿信息，然后将这个草稿取消" do
  #    lifei = users(:lifei)
  #    chengliwen,hanmeimei = users(:chengliwen),users(:hanmeimei)
  #    receiver_str_arr = users_to_params_receivers([lifei,chengliwen,hanmeimei])
  #    entry = resource_entries(:entry_file_1)
  #    send_message_no_self
  #
  #    reply_message = Message.last
  #    assert_equal [1,3], [Message.count,MessageReading.count]
  #
  #    uuid = UUID.random_create.to_s
  #    # message 的发件人是 songliang 收件人是 lifei chengliwen
  #    post 'create',:namespace=>'site_mail',:resource_entry_ids=>[entry.id],:message=>{:draft=>true,:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    draft_message = Message.last
  #    assert draft_message.draft?
  #    assert_equal draft_message.reply_to,reply_message.id
  #    assert_equal Message.count,2
  #    assert_equal MessageReading.count,3
  #    assert_equal draft_message.content,'我回！但是不发送'
  #    post 'cancel_create',:resource_entry_ids=>[entry.id],:message=>{:reply_to=>reply_message.id,:title=>'又是一个回复',:content=>'我回！但是不发送.中国人民是中国人民',:receiver_str_arr=>receiver_str_arr,:uuid=>uuid}
  #    assert_equal Message.count,1
  #    assert_equal MessageReading.count,3
  #  end
  
  #================================================================

  #  test "用户给message_topic 增加 tag" do
  #    Tagging.all.each{|x| x.destroy}
  #    Tag.all.each{|x| x.destroy}
  #    lifei = users(:lifei)
  #    songliang = users(:songliang)
  #    chengliwen = users(:chengliwen)
  #    session[:user_id] = lifei.id
  #
  #    songliang.send_message_to(:receivers=>[lifei,chengliwen],:title=>'我是标题',:content=>'大家好！')
  #    topic_1 = Message.last.topic
  #    li_reading_1 = topic_1.reading_of(lifei)
  #    songliang.send_message_to(:receivers=>[lifei,chengliwen],:title=>'我是标题',:content=>'大家好！')
  #    topic_2 = Message.last.topic
  #    li_reading_2 = topic_2.reading_of(lifei)
  #
  #    get 'edit_tags',:reading_ids=>[li_reading_1.id,li_reading_2.id],:box=>'inbox'
  #    assert_response :success
  #    put 'update_tags',:reading_ids=>[li_reading_1.id,li_reading_2.id],:tags_str=>"好文章,最新技术",:box=>'inbox'
  #    assert_equal "好文章,最新技术",topic_1.tags_str_of(lifei)
  #    assert_equal "",topic_1.tags_str_of(songliang)
  #    put 'update_tags',:reading_ids=>[li_reading_1.id,li_reading_2.id],:tags_str=>"无聊文章,过时技术,火星",:box=>'inbox'
  #    assert_equal "无聊文章,过时技术,火星",topic_1.tags_str_of(lifei)
  #    assert_equal "",topic_1.tags_str_of(songliang)
  #  end

end