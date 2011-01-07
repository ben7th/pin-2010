class InvitationsController < ApplicationController
  before_filter :login_required,:only=>[:create]
  include SessionsMethods

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
    @email = params[:email]
    render :layout=>'auth'
  end

  def import_invite
    emails = params[:emails]
    if !emails.blank?
      emails.each do |email|
        InvitationEmail.new(current_user.email,email).send
      end
    end
    return render :text=>"保存成功" , :status=>200
  rescue Exception=>ex
    return render :text=>ex.message , :status=>500
  end

  class ConcatSaveError < StandardError;end
  def import_concat
    emails = params[:emails]
    if !emails.blank?
      Concat.transaction do
        !emails.each do |email|
          concat = current_user.concats.new(:email=>email.strip())
          if !concat.save
            raise ConcatSaveError,concat.errors.first[1]
          end
        end
      end
    end
    return render :text=>"保存成功" , :status=>200
  rescue ConcatSaveError => ex
    return render :text=>ex.message , :status=>500
  end

end