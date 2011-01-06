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
#    Thread.start{
    Mailer.deliver_invite(self)
#    }
  end

  # 被邀请人 注册成功后 互相加为联系人
  def done
    @sender.actor.concats.create(:email=>@receiver.email)
    @receiver.actor.concats.create(:email=>@sender.email)
  end

end