class Mailer < ActionMailer::Base
  
  # 欢迎某人加入工作空间
  def welcome_to_workspace(workspace,message,email)
    @recipients = email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'workspace' => workspace,"message"=>message,"membership"=>Membership.find_by_workspace_id_and_email(workspace.id,email)}
    @subject = "欢迎加入#{workspace.user.name}的工作空间"
    @sent_on = Time.now
    @content_type = "text/html"
  end

  # 邀请某人加入工作空间
  def invite_to_workspace(workspace,message,email)
    @recipients = email
    @from = 'MindPin<noreply@mindpin.com>'
    @body = {'workspace' => workspace,"message"=>message,"membership"=>Membership.find_by_workspace_id_and_email(workspace.id,email)}
    @subject = "邀请您加入#{workspace.user.name}的工作空间"
    @sent_on = Time.now
    @content_type = "text/html"
  end

end