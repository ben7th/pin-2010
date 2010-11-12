class EntriesController < ApplicationController

  before_filter :login_required
  before_filter :pre_load

  def new
    case params[:type]
    when 'subscription'
      render_ui do |ui|
        ui.fbox :show,:partial=>"/entries/form_subscription_entry",:locals=>{:type=>params[:type]},:title=>"创建订阅"
      end
    end
  end

  # 创建资源
  def create
    return create_subscription_entry(params, current_user) if params[:type] == 'subscription'
    entry = Entry.new(params[:entry])
    entry.user = current_user
    respond_to do |format|
      format.xml do
        if entry.save
          render :xml=>entry,:status=>:created,:location=>entry
        else
          render :xml=>entry.errors,:status=>:unprocessable_entity
        end
      end
    end
  end

  def create_subscription_entry(params,current_user)
    begin
      rss_feed = RssFeed.create_rss_feed(params[:url])
      entry = SubscriptionEntry.create_subscription_entry(current_user,rss_feed)
      if entry
        return render_success(entry)
      end
    rescue Exception => ex
      return show_error(ex.to_s)
    end
  end

  # 在entries的订阅中添加订阅
  def render_success(entry)
    if params[:sign]
      render_ui do |ui|
        ui.mplist :insert,entry,:partial=>"/reader/parts/info_subscription_entry",:locals=>{:entrty=>entry},:prev=>'TOP'
        ui.fbox :close
        ui.page << %`
          $$('.loadingbox .loading-tip')[0].setStyle({'display':'none'});
          $$('.loadingbox .loading-img')[0].setStyle({'display':'none'});
          $$('.loadingbox .messages_of_add_subscription')[0].update('订阅成功');
        `
      end
      return
    end
    render_ui do |ui|
      ui.mplist :insert,entry,:partial=>"entries/info_entry",:locals=>{:entrty=>entry},:prev=>'TOP'
      ui.fbox :close
    end
  end

  # 展现错误
  def show_error(content)
    render_ui do |ui|
      ui.page << %`
        $$('.loadingbox .loading-tip')[0].setStyle({'display':'none'});
        $$('.loadingbox .loading-img')[0].setStyle({'display':'none'});
        $$('.loadingbox .messages_of_add_subscription')[0].update('#{content}');
      `
    end
  end

  # 显示全部资源，包括所有类型的
  def index
    order = params[:order_by].blank? ? "created_at_desc" : params[:order_by]
    @entries = current_user.entries.type_of(params[:type]).order(order).paginate(:page => params[:page] ,:per_page=>Entry.per_page )
  end

  def show
    respond_to do |format|
      format.xml do
        render :xml=>@entry.to_xml(:include=>:resource)
      end
      format.any do
        render :template=>"entries/show"
      end
    end
  end

  # 增加标签的页面
  def edit_tags
    if params[:entry_ids]
      render_ui do |ui|
        ui.fbox :show,:partial=>'/entries/form_tag',:title=>I18n.t('page.entries.edit_tags'),:locals=>{:entry_ids=>params[:entry_ids]}
      end
      return 
    end
    render :text=>""
  end

  # 增加标签
  def update_tags
    @entries = Entry.find(params[:entry_ids])
    if params[:tags_str]
      render_ui do |ui|
        @entries.each do |entry|
          entry.set_user_tags!(current_user,params[:tags_str])
          ui.mplist(:update,entry,:partial=>"entries/info_entry",:locals=>{:checked=>true})
        end
        ui.page.close_box
      end
    end
  end

  # 根据标签的载体属性，决定渲染的模板
  def render_mplist_by_resource_type(template)
    render_mplist :update=>@entry.resource,:partial=>template do |page|
      page.close_box
    end
  end

  def destroys
    return render :text=>"" if params[:entry_ids].blank?
    render_ui do |ui|
      Entry.find(params[:entry_ids]).each do |entry|
        entry.destroy
        ui.mplist(:remove,entry)
      end
    end
  end

  def download
    file_entry = @entry.resource
    path = file_entry.content.path
    send_file path,:filename=>file_entry.file_name
  end

  def zip_download
    resource = @entry.resource
    zip_path = resource.to_zip
    send_file zip_path,:filename=>resource.title + ".zip"
  end

  def send_zip_email
    @entry.send_zip_mail_to(current_user)
    flash[:success] = "邮件发送成功"
    redirect_to :action=>"show"
  end

  def send_email
    @entry.send_mail_to(current_user)
    flash[:success] = "邮件发送成功"
    redirect_to :action=>"show"
  end

  def edit
    case @entry.resource
    when BookmarkEntry
      render_ui do |ui|
        ui.fbox :show,:partial=>'/entries/form_bookmark_entry',:title=>"编辑",:locals=>{:entry=>@entry}
      end
      return
    end
  end

  def update
    if @entry.update_attributes(params[:entry])
      render_ui do |ui|
        ui.page.close_box
        ui.mplist :update,@entry
      end
      return
    end
  end

  def snapshot
  end

  def snapshot_html
    begin
      resource = @entry.resource
      @content = resource.get_snapshot(resource.url,:redirect_count=>0)
      response.charset = "Auto"
      render :layout=>false
    rescue Exception => ex
      render :stats=>500,:text=>"nothing"
    end
  end

  def search
    keyword = params[:keyword]
    entries = case params[:type]
    when 'bookmark'then BookmarkEntry.search(keyword,current_user)
    when 'file' then FileEntry.search(keyword,current_user)
    when 'text' then TextEntry.search(keyword,current_user)
    end
    @entries = entries.paginate(:page => params[:page] ,:per_page=>Entry.per_page )
  end
  
  def pre_load
    @entry = Entry.find(params[:id]) if params[:id]
  end

end

