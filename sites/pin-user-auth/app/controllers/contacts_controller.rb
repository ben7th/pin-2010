class ContactsController < ApplicationController
  before_filter :login_required,:except=>[:fans,:followings]
  before_filter :per_load
  def per_load
    @contact = Contact.find(params[:id]) if params[:id]
  end

  def create
    email = params[:contact][:email].strip()
    return _render_error_message("请填写你要增加的联系人的用户邮箱") if email.blank?
    contact_user = User.find_by_email(email)
    return _render_error_message("没有找到这个用户") if contact_user.blank?
    @contact = current_user.add_contact_user(contact_user)
    if @contact.valid?
      render :partial=>"contacts/manage/mplist_followings_users",:locals=>{:users=>[@contact.contact_user]}
      return
    end
    _render_error_message(@contact.errors.first[1])
  end

  def _render_error_message(message)
    render :text=>message,:status=>503
  end

  def create_for_plugin
    email = params[:email].strip()
    @contact = current_user.add_contact_user(User.find_by_email(email))
    if @contact.valid?
      user = @contact.contact_user
      data = !!user ? [{:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url()},{:id=>@contact.id,:email=>@contact.email}] : [{},{:id=>@contact.id,:email=>@contact.email}]
      return render :status=>200,:json=>data.to_json
    end
    render :status=>:unprocessable_entity,:text=>@contact.errors.first[1]
  end

  def destroy_for_plugin
    @contact = Contact.find(params[:id])
    if @contact.destroy
      return render :status=>200,:text=>"删除成功"
    end
    return render :status=>400,:text=>"删除失败"
  end

  def destroy
    if @contact.destroy
      render_ui do |ui|
        ui.page << %~
          if(jQuery('#mplist_contacts li').length == 1){
            jQuery('.no-member').show();
          }
        ~
        ui.mplist :remove,@contact
      end
    end
  end

  def index
    respond_to do |format|
      format.html{}
      format.json do
        contacts_arr = current_user.contacts.map do |c|
          user = c.contact_user
          if user
            [{:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url()},{:id=>c.id,:email=>c.email}]
          else
            [{},{:id=>c.id,:email=>c.email}]
          end
        end
        render :json=> contacts_arr.to_json
      end
    end
  end

  def import
    set_cellhead_path("contacts_setting/cellhead")
  end
  
  def import_list
    begin
      @email_hash = EmailContact.fetch_email_contacts(params[:email_login],params[:password],params[:type],current_user)

      @already_contact_email_actors = @email_hash[:already_contact_email_actors]
      @not_contacts_already_regeist_email_actors = @email_hash[:not_contacts_already_regeist_email_actors]
      @not_contact_not_regeist_email_actors = @email_hash[:not_contact_not_regeist_email_actors]
    rescue Contacts::AuthenticationError => ex
      flash[:error] = "邮箱或密码错误"
      redirect_to "/contacts_setting/import"
    rescue Exception => ex
      flash[:error] = ex.message
      puts ex.backtrace*"\n"
      redirect_to "/contacts_setting/import"
    end
  end

  def fans
    @user = User.find(params[:user_id])
    @fans = @user.fans.paginate(:per_page=>15,:page=>params[:page]||1)
    render :template=>"contacts/manage/fans"
  end

  def followings
    @user = User.find(params[:user_id])
    @followings = @user.followings.paginate(:per_page=>15,:page=>params[:page]||1)
    render :template=>"contacts/manage/followings"
  end

  def follow
    contact_user = User.find(params[:user_id])
    if FollowOperationQueueWorker.async_follow_operate(FollowOperationQueueWorker::FOLLOW_OPERATION,current_user,contact_user)
      return render :status=>200,:text=>"关注成功"
    end
    render :status=>500,:text=>"关注失败"
  end

  def unfollow
    contact_user = User.find(params[:user_id])
    if FollowOperationQueueWorker.async_follow_operate(FollowOperationQueueWorker::UNFOLLOW_OPERATION,current_user,contact_user)
      return render :status=>200,:text=>"取消关注成功"
    end
    render :status=>500,:text=>"取消关注失败"
  end

end
