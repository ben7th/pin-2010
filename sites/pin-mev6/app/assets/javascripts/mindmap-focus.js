pie.mindmap.focus = {
  shared_methods :{
    focus : function(){
      jQuery(this.R.board_elm).find('.node').removeClass('focus');
      
      this.R.focus_node = this;
      this.elm.addClass('focus');
      
      this.R.focus_elm.css({
        'left'   : this.left -2-1,
        'top'    : this.top  -6-1,
        'width'  : this.width  +2,
        'height' : this.height +2
      })
      
      this.R.hover_elm.hide();
    },
    
    mousehover : function(){      
      this.R.hover_elm.css({
        'left'   : this.left -2-1,
        'top'    : this.top  -6-1,
        'width'  : this.width  +2,
        'height' : this.height +2
      }).show();
    }
  },
  init : function(R){
    R.focus_node = null;
    
    R.hover_elm = jQuery('<div class="mousehover_box"></div>').appendTo(R.paper_elm).hide();
    
    R.focus_elm = jQuery('<div class="focus_box"></div>').appendTo(R.paper_elm);
    R.data.focus();
    
    jQuery(R.board_elm).find('.node')
      .live('click', function(){
        var node = R.get(jQuery(this).data('id'));
        node.focus();
      })
      .live('mouseenter', function(){
        var node = R.get(jQuery(this).data('id'));
        if(R.focus_node == node) return;
        node.mousehover();
      })
      .live('mouseleave', function(){
        R.hover_elm.hide();
      })
    
    
  }
}
