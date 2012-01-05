module MindmapHistoryRecordsControllerMethods
  
  def self.included(base)
    base.before_filter :check_edit_history_records_right,
      :only=>[:undo,:redo,:history_records,:rollback_history_record]
  end

  def check_edit_history_records_right
    if !logged_in? || !has_edit_rights?(@mindmap,current_user)
      render :status=>411,:text=>"没有编辑权限"
    end
  end

  def undo
    @mindmap.undo
    res = { :map=>@mindmap.struct_hash,
      :can_undo=>@mindmap.can_undo?,
      :can_redo=>@mindmap.can_redo?
    }.to_json

    render :text=>res
  end

  def redo
    @mindmap.redo
    res = { :map=>@mindmap.struct_hash,
      :can_undo=>@mindmap.can_undo?,
      :can_redo=>@mindmap.can_redo?
    }.to_json
    render :text=>res
  end

end
