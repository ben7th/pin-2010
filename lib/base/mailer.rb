class Mailer < ActionMailer::Base
  
  FROM = 'mindpin<noreply@mindpin.com>'
  
  def _subject(method)
    "来自mindpin的#{method}邮件。"
  end

  # 发送密码重设
  def forgotpassword(user)
    @recipients = user.email
    @from = FROM
    @body = {'user' => user}
    @subject = _subject "密码重设"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 用户激活邮件
  def activation(user)
    @recipients = user.email
    @from = FROM
    @body = {'user' => user}
    @subject = _subject "用户激活"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 发送邀请函
  def invite(invitation_email)
    sender = invitation_email.sender.actor
    @recipients = invitation_email.receiver.email
    @from = FROM
    @body = {'invitation_email'=>invitation_email}
    @subject = "来自朋友#{sender.name}的mindpin邀请邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 主题邀请
  def feed_invite(feed,sender,recipient_email,title,postscript)
    @recipients = recipient_email
    @from = FROM
    @body = {'feed' => feed,'postscript' => postscript,'sender' => sender}
    @subject = title
    @sent_on = Time.now
    @content_type = "text/html"
  end
end
