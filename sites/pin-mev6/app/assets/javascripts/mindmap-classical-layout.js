pie.mindmap = pie.mindmap || {};

jQuery.extend(pie.mindmap, {

  do_layout_classical : function(R){    
		var root = R.data;
		/* 喵~ 这就是经典布局的节点排布函数了
		 * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
		 */ 
		
		// 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
		// 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
		
		R.paper_elm.css({
		  'left' : (R.canvas_elm.width() - root.width) / 2, 
			'top'  : (R.canvas_elm.height() - root.height) / 2
		})
    

		// 求出左右两侧坐标排布的起始位置		
		 var left_start_top = (root.height - root.left_children_boxes_total_height()) / 2;
		var right_start_top = (root.height - root.right_children_boxes_total_height()) / 2;
		 var left_start_left =          0 - R.options.node_horizontal_gap;
		var right_start_left = root.width + R.options.node_horizontal_gap;
		
		// 分别递归遍历左右节点，计算坐标，排布
    var _hide_all_children = function(node){
      jQuery.each(node.children, function(index, child){
        _hide_all_children(child);
        child.elm.hide();
      })
    }

    var _r_for_left = function(node, left, top){
      var elm = node.elm.addClass('left');
      
      var children = node.children;
      if(node.closed){
        _hide_all_children(node);
        node.ch_pos(left-node.width, top);
      }else{
	      var _tmp_height = 0;
	      jQuery.each(children, function(index, child){
	        _r_for_left(child, left-node.width-R.options.node_horizontal_gap, top+_tmp_height);
	        _tmp_height += child.subtree_box_height + R.options.node_vertical_gap;
	      })
	      
	      node.ch_pos(left-node.width, top + (node.subtree_box_height - node.height)/2);
			}
    }

    var _r_for_right = function(node, left, top){
      var elm = node.elm.addClass('right');
			
      var children = node.children;
			if(node.closed){
        _hide_all_children(node);
        node.ch_pos(left, top);
			}else{
	      var _tmp_height = 0;
	      jQuery.each(children, function(index, child){
	        _r_for_right(child, left+node.width+R.options.node_horizontal_gap, top+_tmp_height);
	        _tmp_height += child.subtree_box_height + R.options.node_vertical_gap;
	      })
				
				node.ch_pos(left, top + (node.subtree_box_height - node.height)/2);
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