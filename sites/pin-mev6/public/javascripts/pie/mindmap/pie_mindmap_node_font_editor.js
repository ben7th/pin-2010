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
    this.sizes_select = $$('#facebox .mindmap-font-editor .sizes select')[0];

    this.fontsize  = this.node.get_fontsize();
    this.fontcolor = this.node.get_fontcolor();

    jQuery(this.current).css('font-size',this.fontsize).css('color',this.fontcolor);
    jQuery(this.sizes_select).val(this.fontsize);
    
    jQuery(this.current).find('span.cc').html(this.fontcolor);
    jQuery(this.current).find('span.cs').html(this.fontsize);

    var current = this.current;
    var e = this;
    jQuery(this.colors).find('.color').bind('click',function(evt){
      var color = jQuery(this).attr('data-color');
      pie.log(color)
      jQuery(current).css('color',color);
      jQuery(current).find('span.cc').html(color);
      e.fontcolor = color;
    });

    jQuery(this.sizes_select).bind('change',function(){
      var elm = jQuery(this);
      var size = elm.val();
      jQuery(current).css('font-size',size + 'px');
      e.fontsize = size;
    })

    jQuery('#facebox .mindmap-font-editor .accept').bind('click',function(evt){
      var node = e.node;
      node.set_fontsize(e.fontsize);
      node.set_fontcolor(e.fontcolor);
      jQuery.facebox.close();

      Object.extend(node,node.el.getDimensions());
      node.do_dirty();
      node.map.reRank();
    });
  }

});