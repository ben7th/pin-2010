pie.mindmap.edit_events = {
  
  shared_methods : {
    relink_children : function(){
      var children = this.children;
      jQuery.each(children, function(index, child){        
        child.prev_node = children[index - 1] || null;
        child.next_node = children[index + 1] || null;
      });
    }
  },
  
  root_methods : {
    do_delete : function(){}
  },
  
  node_methods : {    
    do_delete : function(){
      var R = this.R;  
      // modify data
      this.each_houdai(function(nd){
        R.drop(nd);
      });
      R.drop(this);
      
      this.parent.children = jQuery.array(this.parent.children).without(this).arr;
      this.parent.relink_children();
      
      pie.log(this.parent.children.length);
      pie.log(R.n_count());
      
      // show animation effect
      this.elm.fadeOut();
      this.canvas_elm.fadeOut();
      this.each_houdai(function(nd){
        nd.elm.fadeOut();
        nd.canvas_elm.fadeOut();
      });
      
      this.parent.focus();
      
      var EDIT = pie.mindmap.edit_events;
      
      this.each_zuxian(function(nd){
        nd.canvas_elm.hide();
        nd.redraw_line = true;
      })
      EDIT.do_editing_relayout(R);
      
      // after operation
      //if (this.next) {this.next.select();}
      //else if(this.prev) {this.prev.select();}
      //else {this.parent.select();}
  
      // post data
      //var record = map.opFactory.getDeleteInstance(this);
      //map._save(record);
    }
  },
  
  init : function(R){
    jQuery(document).bind('keydown', 'del', function(){
      pie.log('delete:' + R.focus_node.id);
      R.focus_node.do_delete();
    });
  },
  
  do_editing_relayout : function(R){
    var LAYOUT = pie.mindmap.classical_layout;
    
    LAYOUT.init_paper(R, false);
    LAYOUT.set_nodes_positions(R);
    R.next_animation_mode = 'folding';
    LAYOUT.do_nodes_pos_animate(R);
  }
  
}