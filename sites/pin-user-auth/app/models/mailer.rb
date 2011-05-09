class Mailer < ActionMailer::Base
  
  # 发送密码重设
  def forgotpassword(user)
    @recipients = user.email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'user' => user}
    @subject = "来自MindPin的密码重设邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 用户激活邮件
  def activation(user)
    @recipients = user.email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'user' => user}
    @subject = "来自MindPin的用户激活邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 发送邀请函
  def invite(invitation_email)
    sender = invitation_email.sender.actor
    @recipients = invitation_email.receiver.email
    @from = 'mindpin<noreply@mindpin.com>'
    @body = {'invitation_email'=>invitation_email}
    @subject = "来自朋友#{sender.name}的MindPin邀请邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 话题邀请
  def feed_invite(feed,sender,recipient_email,title,postscript)
    @recipients = recipient_email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'feed' => feed,'postscript' => postscript,'sender' => sender}
    @subject = title
    @sent_on = Time.now
    @content_type = "text/html"
  end
end
