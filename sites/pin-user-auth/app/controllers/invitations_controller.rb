class InvitationsController < ApplicationController
  before_filter :login_required,:only=>[:create]
  include SessionsMethods

  def create
    InvitationEmail.new(current_user.email,params[:invitation][:contact_email]).send
    flash[:success] = "邀请函发送成功"
  rescue Exception=>ex
    flash[:error] = ex.message
  ensure
    redirect_to "/contacts_setting/invite"
  end

  def reg
    @invitation_sender = User.find(params["user_id"])
    @email = params[:email]
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
          contact_user = User.find_by_email(email.strip())
          raise ContactSaveError,"没有#{email} 这个用户" if contact_user.blank?
          contact = current_user.add_contact_user(contact_user)
          if !contact.valid?
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