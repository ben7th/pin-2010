class FilesController < ApplicationController
  before_filter :per_load
  def per_load
    @mindmap = Mindmap.find(params[:mindmap_id]) if params[:mindmap_id]
  end

  def index
    render :partial=>"/files/mindmap_image_page",:locals=>{:mindmap=>@mindmap,:page=>params[:page]}
  end

  # 搜索google图片
  def search_image
    json = GoogleSearch.new(params[:query]).images.map do |image|
      {:uri=>image.uri,:height=>image.height,:width=>image.width,:thumbnail_uri=>image.thumbnail_uri,:thumbnail_height=>image.thumbnail_height,:thumbnail_width=>image.thumbnail_width,:content=>image.content}
    end.to_json
    render :json=>json
  end

  def show_font_editor
    render_ui do |ui|
      ui.fbox(:show,
        :title   => "导图编辑 - 节点颜色",
        :partial => "mindmaps/editor_page/module/font_editor",
        :locals  => {:mindmap=>@mindmap})
      ui.page << 'mindmap._node_font_editor._rails_controller_callback()'
    end
  end

end