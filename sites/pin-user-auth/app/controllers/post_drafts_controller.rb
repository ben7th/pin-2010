class PostDraftsController < ApplicationController
  before_filter :login_required

  def index
  end

  def create
    @post_draft = PostDraft.find_by_draft_token(params[:draft_token])
    if @post_draft.blank?
      _create__new_draft
    else
      if @post_draft.user != current_user
        return render_status_page(401,"没有权限")
      end
      _create__update_draft
    end

    if @post_draft.save
      return render :status=>200,:text=>200
    end
    render :status=>402,:text=>402
  end

  def _create__new_draft
    @post_draft = PostDraft.new(
      :title          => params[:title],
      :detail         => params[:detail],
      :photo_ids    => params[:photo_ids],
      :collection_ids => params[:collection_ids],
      :user           => current_user,
      :draft_token    => params[:draft_token]
    )
  end

  def _create__update_draft
    @post_draft.title          = params[:title] if params[:title]
    @post_draft.detail         = params[:detail] if params[:detail]
    @post_draft.photo_ids      = params[:photo_ids] if params[:photo_ids]
    @post_draft.collection_ids = params[:collection_ids] if params[:collection_ids]
  end

  def destroy
    @post_draft = PostDraft.find_by_draft_token(params[:id])
    if @post_draft.user != current_user
      return render_status_page(401,"没有权限")
    end
    @post_draft.destroy
    render :status=>200,:text=>200
  end

end
