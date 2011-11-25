class HistoryRecord < Mev6Abstract

  DO_INSERT = "do_insert"
  DO_DELETE = "do_delete"
  DO_TITLE = "do_title"
  DO_TOGGLE = "do_toggle"
  DO_IMAGE = "do_image"
  DO_RM_IMAGE = "do_rm_image"
  DO_MOVE = "do_move"
  DO_NOTE = "do_note"
  DO_ADD_LINK = "do_add_link"
  DO_CHANGE_COLOR = "do_change_color"
  DO_CHANGE_FONT_SIZE = "do_change_font_size"
  DO_SET_FONT_BOLD = "do_set_font_bold"
  DO_SET_FONT_ITALIC = "do_set_font_italic"
  DO_NODECOLOR = "do_nodecolor"
  CREATE_MINDMAP = "create_mindmap"

  OPERATIONS = [DO_INSERT,DO_DELETE,DO_TITLE,DO_TOGGLE,
    DO_IMAGE,DO_RM_IMAGE,DO_MOVE,DO_NOTE,DO_ADD_LINK,DO_CHANGE_COLOR,
    DO_CHANGE_FONT_SIZE,DO_SET_FONT_BOLD,DO_SET_FONT_ITALIC,
    DO_NODECOLOR,CREATE_MINDMAP
    ]
  
  belongs_to :mindmap
  validates_inclusion_of :kind,:in =>OPERATIONS

  # kind 操作的类型
  # params_hash 操作的参数
  def self.record_operation(mindmap,option)
    kind = option[:kind]
    params_hash = option[:params_hash]
    operator = option[:operator]
    old_struct = option[:old_struct]
    struct = mindmap.struct
    raise "operation_kind is not a valid" if !OPERATIONS.include?(kind)
    raise "params_hash is not a hash" if !params_hash.is_a?(Hash)

    if mindmap.history_records.blank?
      HistoryRecord.create!(:struct=>old_struct,
        :params_json=>{}.to_json,:mindmap_id=>mindmap.id,
        :kind=>CREATE_MINDMAP,:email=>operator.email)
      mindmap.history_records.reload
    end

    mindmap.clear_useless_history_records

    params_json = params_hash.to_json
    HistoryRecord.create!(:struct=>struct,:params_json=>params_json,:mindmap_id=>mindmap.id,:kind=>kind,:email=>operator.email)
  end

  module MindmapMethods
    def self.included(base)
      base.has_many :history_records,:order=>"history_records.id asc"
    end

    def can_undo?
      chr_id = self.current_history_record_id
      ids = self.history_record_ids

      return false if ids.blank?
      return false if ids.first == chr_id
      return true
    end

    def can_redo?
      chr_id = self.current_history_record_id
      ids = self.history_record_ids

      return false if chr_id.nil?
      return false if ids.blank?
      return false if ids.last == chr_id
      return true
    end

    def undo
      hr = self.prev_history_record
      return if hr.blank?

      self.struct = hr.struct
      self.current_history_record_id = hr.id
      begin
        self.save!
      rescue Exception => ex
        p "~~~mindmap.save error~~~~~"
        p ex.class
        p ex.message
        p "~~~mindmap.save error~~~~~"
        puts ex.backtrace.join("\n")
        raise MindmapOperate::MindmapNotSaveError,"mindmap 数据库记录保存出错"
      end
      self.refresh_thumb_image_in_queue
      self.reload
    end

    def redo
      hr = self.next_history_record
      return if hr.blank?

      self.struct = hr.struct
      self.current_history_record_id = hr.id
      begin
        self.save!
      rescue Exception => ex
        p "~~~mindmap.save error~~~~~"
        p ex.class
        p ex.message
        p "~~~mindmap.save error~~~~~"
        puts ex.backtrace.join("\n")
        raise MindmapOperate::MindmapNotSaveError,"mindmap 数据库记录保存出错"
      end
      self.refresh_thumb_image_in_queue
      self.reload
    end

    def rollback_history_record(hr_id)
      return if !self.history_record_ids.include?(hr_id)

      hr = HistoryRecord.find(hr_id)

      self.struct = hr.struct
      self.current_history_record_id = hr.id
      begin
        self.save!
      rescue Exception => ex
        p "~~~mindmap.save error~~~~~"
        p ex.class
        p ex.message
        p "~~~mindmap.save error~~~~~"
        puts ex.backtrace.join("\n")
        raise MindmapOperate::MindmapNotSaveError,"mindmap 数据库记录保存出错"
      end
      self.refresh_thumb_image_in_queue
      self.reload
    end

    def prev_history_record
      chr_id = self.current_history_record_id
      return self.history_records.last if chr_id.nil?

      ids = self.history_record_ids
      index = ids.index(chr_id)
      return if index == 0

      if index.nil?
        id = ids.last
      else
        id = ids[index-1]
      end
      HistoryRecord.find_by_id(id)
    end

    def next_history_record
      chr_id = self.current_history_record_id
      return if chr_id.nil?

      ids = self.history_record_ids
      index = ids.index(chr_id)
      return if index == (ids.length-1)

      if index.nil?
        id = ids.last
      else
        id = ids[index+1]
      end
      HistoryRecord.find_by_id(id)
    end

    def clear_useless_history_records
      chr_id = self.current_history_record_id
      hrs = self.history_records
      if chr_id.nil?
        # 如果等于20 条 删除最旧的 locus
        hrs[0...-19].each{|hr|hr.destroy}
      else
        # 删除 大于 mindmap.locus_number 的 locus
        hrs = hrs.select{|hr| hr.id > chr_id}
        hrs.each{|hr|hr.destroy}
      end
    end

  end

end
