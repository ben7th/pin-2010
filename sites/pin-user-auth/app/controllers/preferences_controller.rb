class PreferencesController < ApplicationController
  before_filter :login_required,:only=>[:edit]
  before_filter :pre_load

  def edit
  end

  def update
    if params[:set_default_app]
      current_user.default_app_id = params[:default_app_id]
    end
    if params[:set_usually_used_apps]
      current_user.set_usually_used_app_ids= params[:usually_used_app_ids]
    end
    if @preference.update_attributes(params[:preference])
      render_ui do |ui|
        ui.page << %`
        var notice = $('change_theme_message')
        notice.removeClassName("hide")
        notice.update('修改成功')
        `
      end
      return
    end
    flash.now[:notice] = '修改失败'
    return render_page :position=>:paper,:edit=>@preference,:partial=>"preferences/cell_edit"
  end

  def ajax_theme_change
    return render :partial=>"preferences/form_preference",:locals=>{:preference=>@preference}
  end

  def pre_load
    @preference = Preference.find_or_create_by_user_id(current_user.id)
  end

end