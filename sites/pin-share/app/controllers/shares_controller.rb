class SharesController < ApplicationController
  before_filter :per_load
  skip_before_filter :verify_authenticity_token,:only=>:add_on_shares

  def new
    render_ui do |ui|
      ui.fbox :show,:title=>"分享",:partial=>"/shares/form_share",:locals=>{:share => Share.new,:shareable=>@shareable}
    end
  end

  def add_on_shares
    share = Share.new(:content=>params[:content],:kind=>Share::TALK)
    share.creator = current_user
    if share.save
      return render :text=>"200",:status=>200
    end
    return render :text=>"500",:status=>500
  end

  def create
    share = Share.new_by_params(params[:share],@shareable,params[:entry_id])
    share.creator = current_user
    respond_to do |format|
      format.xml do
        share.save
        render :xml=>share.to_xml
      end
      format.any do
        if share.save
          return render_success(share)
        else
          return render_failure
        end
      end
    end
  end

  def render_success(share)
    render_ui do |ui|
      # 首先，在列表里插入一行
      ui.mplist :insert,[share.creator,share],:partial=>"/shares/parts/mpinfo_share",:prev=>"TOP"
      # 关闭浮动窗
      ui.fbox :close
      # 刷新叶面计数
      _refresh_share_count(ui,@shareable)
    end
  end

  def _refresh_share_count(ui,shareable)
    if shareable
      # 找到原文所在的li，更新其中的计数span
      ui.page << %~
        try{
          var count_link = $('share_#{shareable.id}').down('.share_count').down('a');
          count_link.update('#{text_num("转发",shareable.shared_count)}');
        }catch(e){}
      ~
      # 找到转发原文的引用块的计数span，更新之
      data_share = "#{shareable.type}_#{shareable.id}"
      ui.page << %~
        $$("[data-share='#{data_share}']").each(function(span){
          $(span).down('a').update('#{text_num("原文转发",shareable.shared_count)}');
        });
      ~
    end
  end

  def render_failure
    render_ui do |ui|
      ui.page.visual_effect(:highlight, 'share_content',:duration => 0.3)
    end
  end

  def img
    params[:entry][:resource_meta][:type] = "FileEntry"
    entry = Entry.new(params[:entry])
    entry.user = current_user
    entry.save
    file_entry = entry.resource
    img_title = file_entry.title
    img_src = file_entry.content.url(:s120)
    responds_to_parent do
      render :update do |page|
        img_div = @template.render :partial=>"shares/parts/share_img_input",:locals=>{:entry=>entry}
        page << %`
        // 文件上传完成后，显示文件名称，并提供可删除的文件的按钮
        var form = $('new_share');
        var text_area = form.down('textarea#share_content');
        text_area.value = text_area.value + ' 分享图片';
        // 显示图片
        $('share_img').prototip.show();
        $('share_img').tip_instant.tip.update("<div><img src='#{img_src}' /></div>")

        form.down(".share_img_input").replace(#{img_div.to_json});
        var file_name_span = form.down("span.upload_file_name");
        file_name_span.update(#{img_title.to_json});
        file_name_span.removeClassName('hide')
        form.down('span.when_file_is_uploading').addClassName('hide')
        $('entry_resource_meta_data_content').addClassName('hide');
        $('delete_file_button').removeClassName('hide');
        `
      end
    end
  end

  def video
    url = params[:entry][:resource_meta][:data][:url]
    if BookmarkEntry.has_video?(url)
      params[:entry][:resource_meta][:type] = "BookmarkEntry"
      _create_entry
      render :update do |page|
        page << %`
        $('share_video').prototip.hide();
        var new_share_div = $('new_share');
        var text_area = new_share_div.down('textarea#share_content');
        text_area.value = text_area.value + ' #{ShortUrl.get_short_url(url)}';
        `
      end
      return
    end
    render :update do |page|
      page << %`
      var form_div = $('share_video').tip_instant.tip.down("form")
      form_div.down('.error_tip').removeClassName('hide')
      `
    end
  end

  def audio_valid
    url = params[:entry][:resource_meta][:data][:url]
    if BookmarkEntry.is_audio_url?(url)
      bme = BookmarkEntry.f_by_user_and_url(current_user,url)
      title = bme.blank? ? "":bme.title
      render :update do |page|
        page << %`
        var form_div = $('share_audio').tip_instant.tip.down("form")
        form_div.down('.error_tip').addClassName('hide')
        form_div.down('.audio_info').removeClassName('hide')
        form_div.down(".audio_info input[type='text']").value = #{title.to_json}
        `
      end
      return
    end
    _audio_valid_fail_rjs
  end

  def audio
    url = params[:entry][:resource_meta][:data][:url]
    if BookmarkEntry.is_audio_url?(url)
      params[:entry][:resource_meta][:type] = "BookmarkEntry"
      entry = _create_entry
      title = entry.resource.title
      render :update do |page|
        page << %`
        var form_div = $('share_audio').tip_instant.tip.down("form")
        form_div.down('.error_tip').addClassName('hide')
        form_div.down('.audio_info').addClassName('hide')
        $('share_audio').prototip.hide();
        var new_share_div = $('new_share');
        var text_area = new_share_div.down('textarea#share_content');
        text_area.value = text_area.value + ' #{title} #{ShortUrl.get_short_url(url)}';
        `
      end
      return
    end
    _audio_valid_fail_rjs
  end

  def _audio_valid_fail_rjs
    render :update do |page|
      page << %`
        var form_div = $('share_audio').tip_instant.tip.down("form")
        form_div.down('.error_tip').removeClassName('hide')
        form_div.down('.audio_info').addClassName('hide')
      `
    end
  end

  def _create_entry
    url = params[:entry][:resource_meta][:data][:url]
    title = params[:entry][:resource_meta][:data][:title]
    entry = current_user.entries.bookmark_url_is(url)[0]
    if entry.blank?
      entry = Entry.new(params[:entry])
      entry.user = current_user
      entry.save
    else
      if !title.blank?
        entry.resource.update_attributes(:title=>title)
      end
    end
    return entry
  end

  def destroy
    @share.destroy
    render_ui do |ui|
      ui.mplist :remove,@share
      _refresh_share_count(ui,@share.shareable)
    end
  end

  def show
  end

  def per_load
    @shareable = RssItem.find(params[:rss_item_id]) if params[:rss_item_id]
    @shareable = Share.find(params[:share_id]) if params[:share_id]
    @share = Share.find(params[:id]) if params[:id]
  end
end
