// 用来包装坐标点的类，此处的坐标并非笛卡尔坐标
// 而是css中的left和top
pie.mindmap.point = function(x, y){
  this.x = x;
  this.y = y;
}

pie.mindmap.draw = {
  // 根据指定的线宽的一半:c 从 p1 -> p2 画一条曲线
  draw_a_line : function(ctx, p1, p2, c){    
    // c 是线宽的一半
    var x1 = p1.x; var y1 = p1.y;
    var x2 = p2.x; var y2 = p2.y;
    
    var dx = x2-x1;
    var dy = y2-y1;
    var ds = Math.sqrt(dx*dx + dy*dy); //算出斜边长
    
    var dxoff = c*dy/ds;
    var dyoff = c*dx/ds;
    
    var xa = x1 - dxoff; var ya = y1 + dyoff;
    var xb = x1 + dxoff; var yb = y1 - dyoff;
    
    var xma = (xa + x2)/2;
    var xmb = (xb + x2)/2;
    
    ctx.beginPath();
    ctx.moveTo(xa, ya);
    ctx.bezierCurveTo(
      xma, ya,
      xma, y2,
      x2 , y2
    );
    ctx.bezierCurveTo(
      xmb, y2,
      xmb, yb,
      xb , yb
    );
    ctx.closePath();
    ctx.fill();
  }
}

pie.mindmap.classical_layout_lines = {
  shared_methods : {
    draw_subtree_lines : function(stop_fadein){
      if(this.closed) return;
      
      var DRAW = pie.mindmap.draw;
      
      var ctx = this.get_ctx();
      var line_width = this.line_width;
      var start_point = this.line_start_point();
      
      jQuery.each(this.children, function(index, child){
        child.draw_subtree_lines(stop_fadein);
        
        var end_point = child.line_end_point();
        DRAW.draw_a_line(ctx, start_point, end_point, line_width);
      })
      
      if(!stop_fadein){
        this.canvas_elm.delay(this.R.options.INIT_ANIMATION_PERIOD).fadeIn(this.R.options.INIT_ANIMATION_PERIOD);
      }
    },
    
    draw_self_lines : function(){
      if(this.closed) return;
      
      var DRAW = pie.mindmap.draw;
      
      var ctx = this.get_ctx();
      var line_width = this.line_width;
      var start_point = this.line_start_point();
      
      jQuery.each(this.children, function(index, child){        
        var end_point = child.line_end_point();
        DRAW.draw_a_line(ctx, start_point, end_point, line_width);
      })
      
      this.canvas_elm.show();
    }
  },
  
  root_methods : {
    get_ctx : function(){
      var R = this.R;
      var X_GAP = R.options.NODE_X_GAP;
      
      var cl = -X_GAP; 
      var cw = this.width + X_GAP * 2;
      var ch = this.visible_height();
      var ct = - (ch - this.height) / 2;
      
      this.canvas_elm
        .css({'left':cl, 'top':ct})
        .attr('width', cw)
        .attr('height', ch);
      
      var ctx = this.canvas_elm[0].getContext('2d');
      ctx.translate(X_GAP, (ch - this.height)/2);
      ctx.fillStyle = '#555';
      
      return ctx;
    },
    
    line_start_point : function(){
      var x = this.width /2;
      var y = this.height/2;
      return new pie.mindmap.point(x, y);
    },
    
    line_width : 5,
    closed : false
  },
  
  node_methods : {
    get_ctx : function(){
      var R = this.R;
      var X_GAP = R.options.NODE_X_GAP;
      var is_left = this.is_left();
      
      var cl = is_left ? this.left -  X_GAP : this.left + this.width;
      var cw = X_GAP; 
      var ch = this.real_subtree_box_height(); 
      var ct = this.top - this.node_box_top_offset();
      
      this.canvas_elm
        .css({'left':cl, 'top':ct})
        .attr('width', cw)
        .attr('height', ch);
      
      var ctx = this.canvas_elm[0].getContext('2d');
      
      if(is_left){
        ctx.translate(       X_GAP - this.left, this.node_box_top_offset() - this.top)
      }else{
        ctx.translate(- this.width - this.left, this.node_box_top_offset() - this.top);
      }
      ctx.fillStyle = '#555';
      
      return ctx;
    },
    
    line_start_point : function(){
      var _FD_CANVAS_OFFSET = this.R.options._FD_CANVAS_OFFSET;
      var x = this.is_left() ? this.left - _FD_CANVAS_OFFSET : this.left + this.width + _FD_CANVAS_OFFSET;
      var y = this.y_center;
      return new pie.mindmap.point(x, y);
    },
    
    line_end_point : function(){
      var x = this.is_left() ? (this.left + this.width) : (this.left);
      var y = this.y_center;
      return new pie.mindmap.point(x, y);
    },
    
    line_width : 2
  },
  
  init : function(R){
    var LAYOUT_LINES = pie.mindmap.classical_layout_lines;
    
    R.data.draw_subtree_lines();
  }
}