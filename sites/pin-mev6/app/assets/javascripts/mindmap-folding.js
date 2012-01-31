pie.mindmap.folding = {
  node_methods : {
    toggle_closed : function(){
      var period = this.R.options.RELAYOUT_ANIMATION_PERIOD;
      var FOLDING = pie.mindmap.folding;
      
      if(this.closed){
        this.fd_elm.removeClass('close').addClass('open');
        this.closed = false;
        this.canvas_elm.fadeIn(period);
      }else{
        this.fd_elm.removeClass('open').addClass('close');
        this.closed = true;
        this.canvas_elm.fadeOut(period);
      }
      
      this.each_zuxian(function(nd){
        nd.canvas_elm.hide();
        nd.will_redraw_self_line = true;
      })
      this.will_redraw_subtree_line = true;
      //deal in pie.mindmap.classical_layout
      
      FOLDING.do_folding_relayout(this.R);
    }
  },
  
  init : function(R){
    // 绑定折叠展开事件
    jQuery(R.board_elm).find('.node .fd').live('click', function(){
      var elm = jQuery(this);
      
      var node_id = elm.closest('.node').data('id');
      var node = R.get(node_id);
      
      node.toggle_closed();
    })
  },
  
  do_folding_relayout : function(R){
    var LAYOUT = pie.mindmap.classical_layout;
    
    LAYOUT.init_paper(R, false);
    LAYOUT.set_nodes_positions(R);
    R.next_animation_mode = 'folding';
    LAYOUT.do_nodes_pos_animate(R);
  }
}