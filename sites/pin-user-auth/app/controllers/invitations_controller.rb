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

  class ContactSaveError < StandardError;end
  def import_contact
    emails = params[:emails]
    if !emails.blank?
      Contact.transaction do
        !emails.each do |email|
          contact = current_user.contacts.new(:email=>email.strip())
          if !contact.save
            raise ContactSaveError,contact.errors.first[1]
          end
        end
      end
    end
    return render :text=>"保存成功" , :status=>200
  rescue ContactSaveError => ex
    return render :text=>ex.message , :status=>500
  end

end