pie.mindmap.NodeFontEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
	},
  do_edit_font:function(mindmap_node){
    this.node = mindmap_node;
		this.node.select();

    this._show_selector_box();
  },

  _show_selector_box:function(){
    new Ajax.Request('/mindmaps/'+this.map.id+'/files/f_editor',{
      method:'GET'
      //回调在controller里
    })
  },

  _rails_controller_callback:function(){
    //这样不太dry，CV层逻辑有些混，暂时先如此
    this.colors       = $$('#facebox .mindmap-font-editor .colors')[0];
    this.current      = $$('#facebox .mindmap-font-editor .current')[0];

    this.bgcolor = this.node.get_bgcolor();
    this.textcolor = this.node.get_textcolor();

    jQuery(this.current)
      .css('background-color',this.bgcolor)
      .css('color',this.textcolor);

    var current = this.current;
    var e = this;
    
    jQuery(this.colors).find('.color').bind('click',function(evt){
      var bg_color = jQuery(this).attr('data-bg-color');
      var text_color = jQuery(this).attr('data-text-color');
      pie.log(bg_color,text_color)
      jQuery(current).css('background-color',bg_color).css('color',text_color);
      e.bgcolor = bg_color;
      e.textcolor = text_color;
    });

    jQuery('#facebox .mindmap-font-editor .accept').bind('click',function(evt){
      var node = e.node;
      node.set_bgcolor(e.bgcolor,e.textcolor);

      var record = e.map.opFactory.getNodeColorInstance(node);
      pie.log(record);
      e.map._save(record);

      jQuery.facebox.close();
    });
  }

});