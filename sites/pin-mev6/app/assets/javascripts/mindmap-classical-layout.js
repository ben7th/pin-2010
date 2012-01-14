pie.mindmap = pie.mindmap || {};

jQuery.extend(pie.mindmap, {

  do_layout_classical : function(R){    
		var root = R.data;
		/* 喵~ 这就是经典布局的节点排布函数乐~~
		 * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
		 */ 
		
		var left_children_boxes_total_height  = root.left_children_boxes_total_height();
		var right_children_boxes_total_height = root.right_children_boxes_total_height();
		
		var left_children_boxes_total_width  = root.left_children_boxes_total_width();
		var right_children_boxes_total_width = root.right_children_boxes_total_width();
		
		// 求出导图可见部分的高度和宽度
		// 设置paper_elm尺寸，根据导图大小乘以一个常数来决定
		var visible_height = jQuery.array([
		  left_children_boxes_total_height,
		  root.height,
		  right_children_boxes_total_height,
		]).max()
		
		var visible_width = (
		  left_children_boxes_total_width +
		  root.width + 
		  right_children_boxes_total_width
	  )
		
		var paper_height =  visible_height * 20;
		var paper_width  =  visible_width * 20;
		 
		// 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
		// 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
		R.paper_elm.css({
		  'width'  : paper_width,
		  'height' : paper_height,
		  'left'   : paper_width, 
			'top'    : paper_height
		})
		
		R.board_elm.scrollLeft(paper_width  + root.width /2 - R.board_elm.width() /2);
		R.board_elm.scrollTop( paper_height + root.height/2 - R.board_elm.height()/2);

		// 求出左右两侧坐标排布的起始位置		
		 var left_start_top  = (root.height -  left_children_boxes_total_height) / 2;
		var right_start_top  = (root.height - right_children_boxes_total_height) / 2;
		 var left_start_left =          0 - R.options.NODE_X_GAP;
		var right_start_left = root.width + R.options.NODE_X_GAP;
		
		var _r = function(node, left, top, is_left){
		  var elm = node.elm.addClass(is_left ? 'left' : 'right');
		  
		  var real_left = is_left ? left-node.width : left;
		  
      if(node.closed){
        node.hide_all_children();
        node.ch_pos(real_left, top);
        return;
      }
      
      var _tmp_height = node.children_box_top_offset();
      jQuery.each(node.children, function(index, child){
			  var new_left = is_left ? real_left - R.options.NODE_X_GAP : real_left + node.width + R.options.NODE_X_GAP;
				var new_top  = top + _tmp_height;
        _r(child, new_left, new_top, is_left);
        _tmp_height += child.real_subtree_box_height() + R.options.NODE_Y_GAP;
      })
      
      node.ch_pos(real_left, top + node.node_box_top_offset());
		}
    
		jQuery.each(root.left_children(), function(index, child){
		  child.elm.addClass('left');
	    _r(child, left_start_left, left_start_top, true);
	    left_start_top += child.real_subtree_box_height() + R.options.NODE_Y_GAP;
		})
		
		jQuery.each(root.right_children(), function(index, child){
		  child.elm.addClass('right');
      _r(child, right_start_left, right_start_top, false);
      right_start_top += child.real_subtree_box_height() + R.options.NODE_Y_GAP;
		})
    
		pie.mindmap.draw_layout_classical(R);
  },
  
  draw_layout_classical : function(R){
    var root = R.data;
    
		var left_children_boxes_total_height  = root.left_children_boxes_total_height();
		var right_children_boxes_total_height = root.right_children_boxes_total_height();
		
		var left_children_boxes_total_width  = root.left_children_boxes_total_width();
		var right_children_boxes_total_width = root.right_children_boxes_total_width();
		
		var visible_height = jQuery.array([
		  left_children_boxes_total_height,
		  root.height,
		  right_children_boxes_total_height,
		]).max()
		
		var visible_width = (
		  left_children_boxes_total_width +
		  root.width + 
		  right_children_boxes_total_width
	  )
	  
		var paper_height =  visible_height * 20;
		var paper_width  =  visible_width * 20;
    
	  var top_offset = (root.height - visible_height)/2;
    
		R.canvas_elm = jQuery('<canvas></canvas>')
  		.css({
  		  'left' : paper_width  - left_children_boxes_total_width,
  		  'top'  : paper_height + top_offset
  		})
  		.attr('width',  visible_width)
  		.attr('height', visible_height).hide().delay(800).fadeIn(800)
		  .prependTo(R.board_elm)
		
		R.ctx = R.canvas_elm[0].getContext("2d");
		R.ctx.translate(left_children_boxes_total_width, -top_offset);
		//R.ctx.globalAlpha = 0.6; 
    //R.ctx.fillStyle = 'rgb(102, 204, 255)';
    R.ctx.fillStyle = '#666';
    R.ctx.strokeStyle = 'rgb(102, 204, 255)';
    R.ctx.lineWidth = 1;
    
    R.ctx.clearRect(0, 0, visible_width, visible_height);
    pie.mindmap._draw_root(root);
  },
  
  _draw_link : function(ctx, x1, y1, x2, y2, c){
      // c 是线宽的一半
      
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
  },
  
  _draw_root : function(root){
    var x1 = root.width/2;
    var y1 = root.height/2;
    
    var ctx = root.R.ctx;
    
    jQuery.each(root.left_children(), function(index, child){
      pie.mindmap._draw_node(child, true);
      var x2 = child.left + child.width;
      var y2 = child.top + child.height/2;
      
      pie.mindmap._draw_link(ctx, x1, y1, x2, y2, 4);
    })
    jQuery.each(root.right_children(), function(index, child){
      pie.mindmap._draw_node(child, false);
      var x2 = child.left;
      var y2 = child.top + child.height/2;
      
      pie.mindmap._draw_link(ctx, x1, y1, x2, y2, 4);
    })
  },
  
	_draw_node : function(node, is_left){
	  if(node.closed) return;
	  
	  var ctx = node.R.ctx;
	  
	  var x1 = is_left ? node.left - 14 : node.left + node.width + 14;
	  var y1 = node.top + node.height/2;
	  
    jQuery.each(node.children, function(index, child){
      pie.mindmap._draw_node(child, is_left);
      
      var x2 = is_left ? (child.left + child.width) : (child.left);
      var y2 = (child.top + child.height/2);
      
      pie.mindmap._draw_link(ctx, x1, y1, x2, y2, 3);
    })
	}
})