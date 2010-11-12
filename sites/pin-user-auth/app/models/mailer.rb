class Mailer < ActionMailer::Base
  
  # 发送密码重设
  def forgotpassword(user)
    @recipients = user.email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'user' => user}
    @subject = "MindPin密码重设邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 用户激活邮件
  def activation(user)
    @recipients = user.email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'user' => user}
    @subject = "MindPin用户激活邮件。"
    @sent_on = Time.now
    @content_type = "text/html"
  end
end
