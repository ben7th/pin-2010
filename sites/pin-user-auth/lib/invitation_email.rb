class InvitationEmail

  attr_reader :sender,:receiver
  
  def initialize(sender_email, receiver_email)
    @sender = EmailActor.new(sender_email)
    @receiver = EmailActor.new(receiver_email)
  end


  class InvitationError < StandardError;end

  # 发送邀请函
  def send
    if @receiver.signed_in?
      raise InvitationError,"被邀请邮箱已经注册过了"
    end
    @sender.actor.update_attributes(:send_invite_email=>true)
    Mailer.deliver_invite(self)
  end

  # 被邀请人 注册成功后 互相加为联系人
  def done
    @sender.actor.contacts.create(:email=>@receiver.email)
    @receiver.actor.contacts.create(:email=>@sender.email)
  rescue Exception=>ex
    p ex
  end

end
