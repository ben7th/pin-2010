pie.mindmap.NodeColorEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;

    this.current = jQuery('.page-mindmap-color-editor .current');

    var func = this;

    //选择颜色
    jQuery(document).delegate('.page-mindmap-color-editor .colors .color','click',function(){
      jQuery('.page-mindmap-color-editor .colors .color').removeClass('selected');
      var elm = jQuery(this);
      elm.addClass('selected');
      var bg_color = elm.attr('data-bg-color');
      var text_color = elm.attr('data-text-color');

      func.current.css('background-color',bg_color).css('color',text_color);
      func.bgcolor = bg_color;
      func.textcolor = text_color;
    });

    //取消
    jQuery(document).delegate('.page-mindmap-color-editor .cancel','click',function(){
      func.close();
    });

    //确定
    jQuery(document).delegate('.page-mindmap-color-editor .accept','click',function(){
      var node = func.node;
      var map = func.map;

      node.set_bgcolor(func.bgcolor,func.textcolor);

      var record = map.opFactory.getNodeColorInstance(node);
      map._save(record);

      func.close();
    });
	},

  //被菜单调用的方法
  do_edit_font:function(mindmap_node){
    this.node = mindmap_node;
		this.node.select();

    this.bgcolor = this.node.get_bgcolor();
    this.textcolor = this.node.get_textcolor();

    this.current
      .css('background-color',this.bgcolor)
      .css('color',this.textcolor);

    //显示对话框
    this._show_selector_box();
  },

  _show_selector_box:function(){
    var height = jQuery(window).height();
    var width = jQuery(window).width();
    var e_elm = jQuery('.page-mindmap-color-editor');

    e_elm.show()
      .css('left', (width - e_elm.outerWidth())/2 )
      .css('top', (height - e_elm.outerHeight())/2 )

    var overlay_elm = jQuery('<div class="page-overlay"></div>')
      .css('opacity',0.4)
      .css('height',height).css('width',width);
    jQuery('body').append(overlay_elm);
  },

  close:function(){
    jQuery('.page-mindmap-color-editor').hide();
    jQuery('.page-overlay').remove();
  }
});