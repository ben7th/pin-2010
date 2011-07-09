class ImageAttachmentsController < ApplicationController
  before_filter :per_load
  def per_load
    @image_attachment = ImageAttachment.find(params[:id]) if params[:id]
  end

  # 删除图片
  def destroy
    @image_attachment.destroy
    render :text=>"destroy success"
  end

  def create
    image_attachment = current_user.image_attachments.create!(:image=>params[:file])
    render :partial=>'mindmaps/editor_page/module/image_editor',:locals=>{:image_attachments=>[image_attachment]}
  end

end