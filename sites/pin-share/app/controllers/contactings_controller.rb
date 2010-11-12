class ContactingsController < ApplicationController

  before_filter :pre_load

  def create
    @user = User.find(params[:contact_id])
    @c_1 = Contacting.create!(:host=>current_user,:contact=>@user)
    @c_2 = Contacting.find_by_host_id_and_contact_id(@user.id,current_user.id)
    list_action_dom_str = @template.render :partial=>"contactings/parts/list_follow_action",:locals=>{:user=>@user}
    action_dom_str = @template.render :partial=>"contactings/parts/follow_action",:locals=>{:user=>@user}
    render_ui do |ui|
      if @c_2
        ui.mplist :update,@c_2,:partial=>"contactings/info_fans",:locals=>{:contacting=>@c_2}
      end
      ui.page << %`
        $$("#follow_#{@user.id}_action").each(function(dom){
          dom.replace(#{action_dom_str.to_json})
        })
        $$("#list_follow_#{@user.id}_action").each(function(dom){
          dom.replace(#{list_action_dom_str.to_json})
        })
      `
    end
  end

  def destroy
    @user = @contacting.contact
    @contacting.destroy
    list_action_dom_str = @template.render :partial=>"contactings/parts/list_follow_action",:locals=>{:user=>@user}
    action_dom_str = @template.render :partial=>"contactings/parts/follow_action",:locals=>{:user=>@user}
    render_ui do |ui|
      ui.mplist :remove,@contacting
      ui.page << %`
        $$("#follow_#{@user.id}_action").each(function(dom){
          dom.replace(#{action_dom_str.to_json})
        })
        $$("#list_follow_#{@user.id}_action").each(function(dom){
          dom.replace(#{list_action_dom_str.to_json})
        })
      `
    end
  end

  def update
    @contacting.update_attribute(:show_share,params[:show_share])
    render_ui do |ui|
      ui.page << "
        var show_share_div = $$('li#contacting_#{@contacting.id} div.actions div.whether_show_share')[0];
        var show_share_span = show_share_div.down('span.show_share_span')
        var not_show_share_span = show_share_div.down('span.not_show_share_span')
        show_share_span.toggleClassName('hide');
        not_show_share_span.toggleClassName('hide');
      "
    end
  end

  def pre_load
    @contacting = Contacting.find(params[:id]) if params[:id]
  end
end
