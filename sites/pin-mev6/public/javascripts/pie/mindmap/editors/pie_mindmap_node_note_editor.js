pie.mindmap.NodeNoteEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
    this.sidebar_jq = jQuery('.mindmap-note-sidebar');

    this.blank_text_jq = this.sidebar_jq.find('.blank-text');
    this.text_jq = this.sidebar_jq.find('.text');
    this.ops_jq = this.sidebar_jq.find('.ops');


    var func = this;

    jQuery(document).delegate('.mindmap-note-sidebar .ops a.edit','click',function(){
      func.map.edit_focus_note();
    });

    //取消
    jQuery(document).delegate('.page-mindmap-note-editor .cancel','click',function(){
      func.close();
    });

    //确定
    jQuery(document).delegate('.page-mindmap-note-editor .accept','click',function(){
      var node = func.node;
      var new_note = jQuery('.page-mindmap-note-editor').find('textarea').val();

      node.set_note_and_save(new_note);
      func.close();
    });

	},

  show_note:function(node){
    var note = jQuery.string(node.note).escapeHTML().str;
    if(node.is_note_blank()){
      this.text_jq.html('').hide();
      this.blank_text_jq.show();
    }else{
      this.text_jq.html(note).show();
      this.blank_text_jq.hide();
    }
  },

  //被菜单调用的方法
  do_edit_note:function(mindmap_node){
    this.node = mindmap_node;
		this.node.select();

    this._show_box();

    jQuery('.page-mindmap-note-editor').find('textarea').val(this.node.note);
  },

  _show_box:function(){
    var height = jQuery(window).height();
    var width = jQuery(window).width();
    var e_elm = jQuery('.page-mindmap-note-editor');

    e_elm.show()
      .css('left', (width - e_elm.outerWidth())/2 )
      .css('top', (height - e_elm.outerHeight())/2 )

    var overlay_elm = jQuery('<div class="page-overlay"></div>')
      .css('opacity',0.4)
      .css('height',height).css('width',width);
    jQuery('body').append(overlay_elm);
  },

  close:function(){
    jQuery('.page-mindmap-note-editor').hide();
    jQuery('.page-overlay').remove();
  }
});