class FeelingsController < ApplicationController

  before_filter :per_load

  def update
    case params[:evaluation]
    when Feeling::GOOD
      @feelable.feel_good_or_cancel_feel(current_user)
    when Feeling::BAD
      @feelable.feel_bad(current_user)
    end
    
    feeling_str = @template.render :partial=>"/feelings/parts/user_feeling",:locals=>{:feelable=>@feelable}
    dom_id = "#{@feelable.class.to_s}_#{@feelable.id}_feeling"
    render_ui do |ui|
      ui.page << %`
        var dom = $('#{dom_id}')
        if(dom){dom.replace(#{feeling_str.to_json})}
      `
    end
  end

  def destroy
    @feeling.destroy
    render_ui do |ui|
      ui.mplist :remove, @feeling
    end
  end

  def per_load
    @feelable = WebSite.find(params[:web_site_id]) if params[:web_site_id]
    @feeling = Feeling.find(params[:id]) if params[:id]
  end
end
