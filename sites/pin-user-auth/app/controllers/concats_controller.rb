class ConcatsController < ActionController::Base
  
  before_filter :per_load
  def per_load
    @concat = Concat.find(params[:id]) if params[:id]
  end

  def create
    @concat = current_user.concats.new(:email=>params[:concat][:email].strip())
    if @concat.save
      render_ui do |ui|
        ui.mplist :insert,@concat
        ui.page << %~  
          jQuery(".add-member-failure-info").html("");
          jQuery("#concat_email").attr("value","");
          jQuery('.no-member').hide();
        ~
      end
      return
    end
    render_ui.page << %~  jQuery(".add-member-failure-info").html("#{@concat.errors.first[1]}") ~
  end

  def create_for_plugin
    @concat = current_user.concats.new(:email=>params[:email].strip())
    if @concat.save
      user = @concat.concat_user
      data = !!user ? [{:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url()},{:id=>@concat.id,:email=>@concat.email}] : [{},{:id=>@concat.id,:email=>@concat.email}]
      return render :status=>200,:json=>data.to_json
    end
    render :status=>:unprocessable_entity,:text=>@concat.errors.first[1]
  end

  def destroy_for_plugin
    @concat = Concat.find(params[:id])
    if @concat.destroy
      return render :status=>200,:text=>"删除成功"
    end
    return render :status=>400,:text=>"删除失败"
  end

  def destroy
    if @concat.destroy
      render_ui do |ui|
        ui.page << %~
          if(jQuery('#mplist_concats li').length == 1){
            jQuery('.no-member').show();
          }
        ~
        ui.mplist :remove,@concat
      end
    end
  end

  def index
    respond_to do |format|
      format.html{}
      format.json do
        concats_arr = current_user.concats.map do |c|
          user = c.concat_user
          if user
            [{:id=>user.id,:name=>user.name,:email=>user.email,:avatar=>user.logo.url()},{:id=>c.id,:email=>c.email}]
          else
            [{},{:id=>c.id,:email=>c.email}]
          end
        end
        render :json=> concats_arr.to_json
      end
    end
  end

end
