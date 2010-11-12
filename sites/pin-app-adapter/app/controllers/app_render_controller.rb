class AppRenderController < ApplicationController
  before_filter :pre_load
  skip_before_filter :verify_authenticity_token,:only=>[:pack]

  def pack
    begin
      if @app
        return render_app
      end
      @html = '应用不存在'
    rescue App::HasToBeRedirect => ex
      logger.debug 'HasToBeRedirect '+ex.url
      redirect_to ex.url,:status=>301
    rescue Errno::ECONNREFUSED => ex
      @html = '<h2 style="margin:10px;">扩展应用连接失败(ExtApp connecting failure)</h2>'
    end
  end

  def render_app
    _fix_params_format
    if request.xhr?
      return _deal_xhr_request
    end
    if params['iframe_ajax']
      return _deal_iframe_ajax_request
    end
    _deal_common_request
  end

  def _fix_params_format
    tmp = params[:path].split('.')
    params[:format] = tmp.length>1 ? tmp[-1]:'html'
  end

  def _deal_xhr_request
    response = @app.open_path_raw_response(request,current_user)

    # 一些特定组件 如 <mp:box> 用到的mplist_json参数，用来指定需要转换的渲染片段以及传其他参数
    if params[:mplist_json]
      # 对json中返回的html进行mpml转换
      json = ActiveSupport::JSON.decode(response.body)
      json['html'] = __parse_haml(json['html'])
      render :js=>json.to_json,:status=>response.code
      return
    end

    # ajax请求返回的片段是否需要进行mpml转换（返回的可能是页面片段或者是js，处理方式是不同的）
    if params[:mpml]
      re = __parse_haml response.body
    else
      re = response.body
    end
    render :js=>re,:status=>response.code
  end

  def _deal_iframe_ajax_request
    responds_to_parent do

      response = @app.open_path_raw_response(request,current_user)

      # 一些特定组件 如 <mp:box> 用到的mplist_json参数，用来指定需要转换的渲染片段以及传其他参数
      if params[:mplist_json]
        # 对json中返回的html进行mpml转换
        json = ActiveSupport::JSON.decode(response.body)
        json['html'] = __parse_haml(json['html'])
        list_id = params['list_id'].to_json
        onsuccess = params['onsuccess']
        render :update do |page|
          page << %~
            pie.mplist.deal_app_json(#{json.to_json.to_json},"app_#{@app.name}",#{list_id});
            close_fbox();
            try{#{onsuccess}(#{json.to_json})}catch(e){}
          ~
        end
      end
    end
  end

  def __parse_haml(str)
    mpml = MPML.new(@app,str)
    return mpml.body
  end

  def _deal_common_request
    respond_to do |format|
      format.html do
        _render_mpml_html
      end
      format.png do
        _send_image_data 'png'
      end
      format.jpg do
        _send_image_data 'jpeg'
      end
      format.gif do
        _send_image_data 'gif'
      end
      format.any do
        _send_raw_text
      end
    end
  end

  def _render_mpml_html
    re,code = @app.open_path_raw(request,current_user)
    @mpml = MPML.new(@app,re,request)
    layout = @mpml.layout
    render 'pack_full',:layout=>layout if layout == false
    render 'pack_tools',:layout=>'app_tools' if layout == 'tools'
    render :status=>code if @app._request_is_api?(request)
  end

  def _send_image_data(type)
    re,code = @app.open_path_raw(request,current_user)
    send_data re, :type=>"image/#{type}", :disposition=>'inline', :status=>code
  end

  def _send_raw_text
    re,code = @app.open_path_raw(request,current_user)
    render :text=>re, :status=>code
  end

  def pre_load
    @app = App.find_by_name(params[:name]) if params[:name]
  end
end