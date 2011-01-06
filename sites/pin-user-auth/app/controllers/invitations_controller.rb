class InvitationsController < ApplicationController
  before_filter :login_required,:only=>[:create]
  include SessionsMethods

  before_filter :invitation_check,:only=>[:show,:regeist]
  def invitation_check
    @invitation = Invitation.find_by_code(params[:id])
    return render_status_page(404,'页面不存在') if @invitation.blank? || @invitation.activated?
  end

  def create
    InvitationEmail.new(current_user.email,params[:invitation][:contact_email]).send
    flash[:success] = "邀请函发送成功"
  rescue Exception=>ex
    flash[:error] = ex.message
  ensure
    redirect_to "/account/invite"
  end

  def reg
    @invitation_sender = User.find(params["user_id"])
    render :layout=>'auth'
  end

  def import_invite
    Invitation.transaction do
      unless params[:nr_emails].blank?
        params[:nr_emails].each do |nr_email|
          Invitation.send_invitation(current_user.email,nr_email)
          current_user.concats.create(:email=>nr_email)
        end
      end
    end
  rescue Invitation::InvitationError=>ex
    flash[:error] = ex.message
  ensure
    redirect_to "/account/concats"
  end

end