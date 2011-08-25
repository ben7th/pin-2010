class FeedDraftsController < ApplicationController
  before_filter :login_required

  def create
    @feed_drafts = FeedDraft.find_by_draft_token(params[:draft_token])
    if @feed_drafts.blank?
      _create__new_draft
    else
      _create__update_draft
    end

    if @feed_drafts.save
      return render :status=>200,:text=>200
    end
    render :status=>402,:text=>402
  end

  def _create__new_draft
    @feed_drafts = FeedDraft.new(:title=>params[:title],:content=>params[:content],
      :text_format=>params[:text_format],:user=>current_user,:draft_token=>params[:draft_token]
    )
  end

  def _create__update_draft
    @feed_drafts.title = params[:title] if params[:title]
    @feed_drafts.content = params[:content] if params[:content]
    @feed_drafts.text_format = params[:text_format] if params[:text_format]
  end


end
