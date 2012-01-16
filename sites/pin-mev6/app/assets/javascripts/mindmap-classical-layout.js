pie.mindmap = pie.mindmap || {};

jQuery.extend(pie.mindmap, {
  
  init_paper : function(R){
    var root = R.data;
    
		var left_children_boxes_total_width  = root.left_children_boxes_total_width();
		var right_children_boxes_total_width = root.right_children_boxes_total_width();
		
		// 求出导图可见部分的高度和宽度
		// 设置paper_elm尺寸，根据导图大小乘以一个常数来决定
		var visible_height = jQuery.array([
		  root.left_children_boxes_total_height(),
		  root.height,
		  root.right_children_boxes_total_height(),
		]).max();
		
		var visible_width = (
		  left_children_boxes_total_width +
		  root.width + 
		  right_children_boxes_total_width
	  );
	  
		var paper_height = visible_height * 20;
		var paper_width  = visible_width * 20;

		// 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
		// 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
		// 这样比较好处理
		R.paper_elm.css({
		  'width'  : paper_width,
		  'height' : paper_height,
		  'left'   : paper_width, 
			'top'    : paper_height
		});
		
		R.board_elm
		  .scrollLeft(paper_width  + root.width /2 - R.board_elm.width() /2)
		  .scrollTop( paper_height + root.height/2 - R.board_elm.height()/2);
    
    // canvas elm
	  var top_offset = (root.height - visible_height)/2;
    
		R.canvas_elm
  		.css({
  		  'left' : paper_width  - left_children_boxes_total_width,
  		  'top'  : paper_height + top_offset
  		})
  		.attr('width',  visible_width)
  		.attr('height', visible_height)
  		.delay(800).fadeIn(800);
    
  	R.ctx = R.canvas_elm[0].getContext("2d");
  	R.ctx.clearRect(0, 0, visible_width, visible_height);
    R.ctx.translate(left_children_boxes_total_width, -top_offset);
    R.ctx.fillStyle = '#555';
  },
  
  do_layout_classical : function(R){
		/* 喵~ 这就是经典布局的节点排布函数乐~~
		 * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
		 */
		pie.mindmap.init_paper(R);
    pie.mindmap.set_nodes_positions(R);  
		pie.mindmap.draw_lines(R);
  },
  
  set_nodes_positions : function(R){
		var root  = R.data;
		var X_GAP = R.options.NODE_X_GAP;
		var Y_GAP = R.options.NODE_Y_GAP;
		
		var _r = function(node, left, top, is_left){
		  var elm = node.elm.addClass(is_left ? 'left' : 'right');
		  
		  var real_left = is_left ? left-node.width : left;
		  
      if(node.closed){
        if(!node.left) node.hide_all_children();
        node.ch_pos(real_left, top);
        return;
      }
      
      var _tmp_height = node.children_box_top_offset();
      jQuery.each(node.children, function(index, child){
			  var new_left = is_left ? real_left - X_GAP : real_left + node.width + X_GAP;
				var new_top  = top + _tmp_height;
        _r(child, new_left, new_top, is_left);
        _tmp_height += child.real_subtree_box_height() + Y_GAP;
      })
      
      node.ch_pos(real_left, top + node.node_box_top_offset());
		}
		
    // 求出左右两侧坐标排布的起始位置
    
    var origin = {
      'left'  : {
        left : 0 - X_GAP,
        top  : (root.height - root.left_children_boxes_total_height())  / 2
      },
      'right' : {
        left : root.width + X_GAP,
        top  : (root.height - root.right_children_boxes_total_height()) / 2
      }
    }
		
		jQuery.each(root.children, function(index, child){
		  var pos = child.pos;
		  var is_left = ('left' == pos);
		  
		  child.elm.addClass(child.pos);
		  _r(child, origin[pos].left, origin[pos].top, is_left);
		  origin[pos].top += child.real_subtree_box_height() + Y_GAP;
		});
  },
  
  draw_lines : function(R){
    var root = R.data
    var ctx = root.R.ctx;
    
    var x1 = root.width /2;
    var y1 = root.height/2;
    
    jQuery.each(root.children, function(index, child){
      var is_left = ('left' == child.pos);
      
      pie.mindmap._draw_node(child, is_left);
      
      var x2 = is_left ? child.left + child.width : child.left;
      var y2 = child.y_center;
      pie.mindmap._draw_line(ctx, x1, y1, x2, y2, 4);  
    })
  },
  
  _draw_line : function(ctx, x1, y1, x2, y2, c){
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
  
	_draw_node : function(node, is_left){
	  if(node.closed) return;
	  var R = node.R;
	  
	  var ctx = R.ctx;
	  var _FD_CANVAS_OFFSET = R.options._FD_CANVAS_OFFSET;
	  
	  var x1 = is_left ? node.left - _FD_CANVAS_OFFSET : node.left + node.width + _FD_CANVAS_OFFSET;
	  var y1 = node.y_center;
	  
    jQuery.each(node.children, function(index, child){
      pie.mindmap._draw_node(child, is_left);
      
      var x2 = is_left ? (child.left + child.width) : (child.left);
      var y2 = child.y_center;
      
      pie.mindmap._draw_line(ctx, x1, y1, x2, y2, 3);
    })
	}
})