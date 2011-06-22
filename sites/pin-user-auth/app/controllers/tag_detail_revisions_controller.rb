class TagDetailRevisionsController < ApplicationController
  before_filter :login_required,:only=>[:rollback]
  before_filter :per_load
  def per_load
    if params[:tag_id]
      @tag = Tag.get_tag_by_full_name(params[:tag_id])
      render_status_page(404,"标签没有找到") if @tag.blank?
    end

    @revision = TagDetailRevision.find(params[:id]) if params[:id]
  end

  def index
    if @tag.full_name != params[:tag_id]
      return redirect_to "/tags/#{@tag.full_name}/revisions"
    end
    @revisions = @tag.tag_detail_revisions
  end

  def show
  end

  def rollback
    if @revision.rollback_detail(current_user)
      return render :text=>"200"
    end
    return render :text=>"401",:status=>401
  end

end
