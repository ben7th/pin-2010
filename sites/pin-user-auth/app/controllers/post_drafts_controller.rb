class PostDraftsController < ApplicationController
  before_filter :login_required

  def create
    @post_drafts = PostDraft.find_by_draft_token(params[:draft_token])
    if @post_drafts.blank?
      _create__new_draft
    else
      _create__update_draft
    end

    if @post_drafts.save
      return render :status=>200,:text=>200
    end
    render :status=>402,:text=>402
  end

  def _create__new_draft
    @post_drafts = PostDraft.new(:title=>params[:title],:detail=>params[:detail],
      :photo_names=>params[:photo_names],:collection_ids=>params[:collection_ids],
      :user=>current_user,:draft_token=>params[:draft_token]
    )
  end

  def _create__update_draft
    @post_drafts.title = params[:title] if params[:title]
    @post_drafts.detail = params[:detail] if params[:detail]
    @post_drafts.photo_names = params[:photo_names] if params[:photo_names]
    @post_drafts.collection_ids = params[:collection_ids] if params[:collection_ids]
  end


end
