class ConcatsController < ActionController::Base
  
  before_filter :per_load
  def per_load
    @concat = Concat.find(params[:id]) if params[:id]
  end

  def create
    @concat = current_user.concats.new(params[:concat])
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

end
