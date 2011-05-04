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

  OPERATIONS = [DO_INSERT,DO_DELETE,DO_TITLE,DO_TOGGLE,
    DO_IMAGE,DO_RM_IMAGE,DO_MOVE,DO_NOTE,DO_ADD_LINK,DO_CHANGE_COLOR,
    DO_CHANGE_FONT_SIZE,DO_SET_FONT_BOLD,DO_SET_FONT_ITALIC
    ]
  
  version 11504
  belongs_to :mindmap
  validates_inclusion_of :kind,:in =>OPERATIONS

  # kind 操作的类型
  # params_hash 操作的参数
  def self.record_operation(mindmap,option)
    kind = option[:kind]
    params_hash = option[:params_hash]
    operator = option[:operator]
    raise "operation_kind is not a valid" if !OPERATIONS.include?(kind)
    raise "params_hash is not a hash" if !params_hash.is_a?(Hash)
   
    params_json = params_hash.to_json
    HistoryRecord.create!(:params_json=>params_json,:mindmap_id=>mindmap.id,:kind=>kind,:email=>operator.email)
  end

end
