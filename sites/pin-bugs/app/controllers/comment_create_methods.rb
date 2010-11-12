module CommentCreateMethods
  def _rjs_form_reset(ui)
    ui.page << "RemarkManager.cancel_reply();"
    ui.page << "RemarkManager.form_reset();"
  end

  def _rjs_insert_info_comment(ui,comment)
    ui.mplist :insert,comment,:partial=>"/comments/parts/mpinfo_comment",:locals=>{:comment=>comment},:prev=>"TOP"
  end

  def _create_comment_for(markable)
    attrs = {}.merge!(params[:comment])
    attrs.merge!(:creator=>current_user)
    markable.create_comment(attrs)
  end
end