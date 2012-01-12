pie.mindmap = pie.mindmap || {};

jQuery.extend(pie.mindmap, {

  do_layout_classical : function(R){    
		var root = R.data;
		/* 喵~ 这就是经典布局的节点排布函数乐~~
		 * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
		 */ 
		
		// 设置paper_elm尺寸，根据导图大小来设置
		var paper_height = jQuery.array([
		  root.left_children_boxes_total_height(),
		  root.height,
		  root.right_children_boxes_total_height(),
		]).max() * 20;
		
		var paper_width = (
		  root.left_children_boxes_total_width() +
		  root.width + 
		  root.right_children_boxes_total_width()
	  ) * 20
		
		 
		// 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
		// 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
		
		R.paper_elm.css({
		  'width'  : paper_width,
		  'height' : paper_height,
		  'left'   : paper_width, 
			'top'    : paper_height
		})
		
		R.canvas_elm.scrollLeft(paper_width);
		R.canvas_elm.scrollTop(paper_height);    

		// 求出左右两侧坐标排布的起始位置		
		 var left_start_top = (root.height - root.left_children_boxes_total_height()) / 2;
		var right_start_top = (root.height - root.right_children_boxes_total_height()) / 2;
		 var left_start_left =          0 - R.options.node_horizontal_gap;
		var right_start_left = root.width + R.options.node_horizontal_gap;
		
		// 分别递归遍历左右节点，计算坐标，排布
    var _r_for_left = function(node, left, top){
      var elm = node.elm.addClass('left');
      
		  var real_left = left - node.width;
			
      var children = node.children;
      if(node.closed){
        node.hide_all_children();
        node.ch_pos(real_left, top);
      }else{
	      var _tmp_height = node.children_box_top_offset();
	      jQuery.each(children, function(index, child){
				  var new_left = real_left - R.options.node_horizontal_gap;
					var new_top  = top + _tmp_height;
	        _r_for_left(child, new_left, new_top);
	        _tmp_height += child.real_subtree_box_height() + R.options.node_vertical_gap;
	      })
	      
	      node.ch_pos(real_left, top + node.node_box_top_offset());
			}
    }

    var _r_for_right = function(node, left, top){
      var elm = node.elm.addClass('right');
			
			var real_left = left;
			
      var children = node.children;
			if(node.closed){
        node.hide_all_children();
        node.ch_pos(real_left, top);
			}else{
	      var _tmp_height = node.children_box_top_offset();
	      jQuery.each(children, function(index, child){
				  var new_left = real_left + node.width + R.options.node_horizontal_gap;
					var new_top  = top + _tmp_height
	        _r_for_right(child, new_left, new_top);
	        _tmp_height += child.real_subtree_box_height() + R.options.node_vertical_gap;
	      })
				
				node.ch_pos(real_left, top + node.node_box_top_offset());
			}
    }
    
		jQuery.each(root.left_children(), function(index, child){
		  child.elm.addClass('left');
	    _r_for_left(child, left_start_left, left_start_top);
	    left_start_top += child.real_subtree_box_height() + R.options.node_vertical_gap;
		})
		
		jQuery.each(root.right_children(), function(index, child){
		  child.elm.addClass('right');
      _r_for_right(child, right_start_left, right_start_top);
      right_start_top += child.real_subtree_box_height() + R.options.node_vertical_gap;
		})
    
  }
	
})