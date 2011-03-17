class ContactsController < ApplicationController
  before_filter :login_required
  before_filter :per_load
  def per_load
    @contact = Contact.find(params[:id]) if params[:id]
  end

  def create
    @contact = current_user.contacts.new(:email=>params[:contact][:email].strip())
    if @contact.save
      render_ui do |ui|
        ui.mplist :insert,@contact
        ui.page << %~  
          jQuery(".add-member-info").html("");
          jQuery("#contact_email").val("");
          jQuery('.no-member').hide();
        ~
      end
      return
    end
    render_ui.page << %~  
      jQuery(".add-member-info").html("#{@contact.errors.first[1]}");
    ~
  end

  def create_for_plugin
    @contact = current_user.contacts.new(:email=>params[:email].strip())
    if @contact.save
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
    set_cellhead_path("users/cellhead")
    @fans = @user.fans
    render :template=>"users/homepage/fans"
  end

  def followings
    @user = User.find(params[:user_id])
    set_cellhead_path("users/cellhead")
    if !params[:channel]
      @followings = @user.followings
    elsif params[:channel] == "none"
      @current_channel = "none"
      @followings = @user.no_channel_contact_users
    else
      @current_channel = @user.channels.find(params[:channel])
      @followings = @current_channel.include_users
    end
    render :template=>"users/homepage/followings"
  end

  def follow
    contact_user = User.find(params[:user_id])
    if FollowOperationQueue.new.add_follow_task(current_user,contact_user)
      return render :status=>200,:text=>"关注成功"
    end
    render :status=>500,:text=>"关注失败"
  end

  def unfollow
    contact_user = User.find(params[:user_id])
    if FollowOperationQueue.new.add_unfollow_task(current_user,contact_user)
      return render :status=>200,:text=>"取消关注成功"
    end
    render :status=>500,:text=>"取消关注失败"
  end

end
