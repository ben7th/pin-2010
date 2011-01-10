class ContactsController < ApplicationController
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
    set_tabs_path('account/tabs')
  end
  
  def import_list
    begin
      @email_hash = EmailContact.fetch_email_contacts(params[:email_login],params[:password],params[:type],current_user)

      @already_contact_email_actors = @email_hash[:already_contact_email_actors]
      @not_contacts_already_regeist_email_actors = @email_hash[:not_contacts_already_regeist_email_actors]
      @not_contact_not_regeist_email_actors = @email_hash[:not_contact_not_regeist_email_actors]
    rescue Contacts::AuthenticationError => ex
      flash[:error] = "邮箱或密码错误"
      redirect_to "/account/concats/import"
    rescue Exception => ex
      flash[:error] = ex.message
      redirect_to "/account/concats/import"
    end
  end

end
