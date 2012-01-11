pie.mindmap = pie.mindmap || {};

jQuery.extend(pie.mindmap, {

  do_layout_classical : function(R){    
		var root = R.data;
		/* 么，这就是经典布局的节点排布函数了
		 * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
		 */ 
		
		// 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
		// 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
		R.paper_elm.css({'left':600, 'top':400})
    
		// 先遍历一次root.children，将一级子节点分为左右两组
		// 分别计算 左侧所有一级子节点 和 右侧所有一级子节点的高度
		// 求出左右两侧坐标排布的起始位置
     root.left_children = [];
    root.right_children = [];
		 left_boxes_total_height = 0;
		right_boxes_total_height = 0;
		
    jQuery.each(root.children, function(index, child){
      switch(child.pos){
        case 'left' : {
          root.left_children.push(child);
					left_boxes_total_height += child.subtree_box_height;
          break;
        }
        case 'right' : {
          root.right_children.push(child);
					right_boxes_total_height += child.subtree_box_height;
          break
        }
        default : {
          root.elm.trigger('mindmap.error.do_layout_failure');
        }
      }
    })
		
		 left_start_top = (root.height - left_boxes_total_height) / 2;
		right_start_top = (root.height - right_boxes_total_height) / 2;
		 left_start_left = -100;
		right_start_left = 100;
		
		// 分别递归遍历左右节点，计算坐标，排布
    
    var _ch_pos = function(node, left, top){
      node.left = left;
      node.top  = top;
      node.elm.animate({'left':node.left, 'top':node.top}, 800);
    }

    var _r_for_left = function(node, left, top){
      var elm = node.elm;
      
      var children = node.children;
      var _tmp_height = 0;
      jQuery.each(children, function(index, child){
        _r_for_left(child, left-node.width-R.options.node_horizontal_gap, top+_tmp_height);
        _tmp_height += child.subtree_box_height + R.options.node_vertical_gap;
      })
      
      _ch_pos(node, left-node.width, top + (node.subtree_box_height - node.height)/2)
    }

    var _r_for_right = function(node, left, top){
      var elm = node.elm;
      
      var children = node.children;
      var _tmp_height = 0;
      jQuery.each(children, function(index, child){
        _r_for_right(child, left+node.width+R.options.node_horizontal_gap, top+_tmp_height);
        _tmp_height += child.subtree_box_height + R.options.node_vertical_gap;
      })
      
      _ch_pos(node, left, top + (node.subtree_box_height - node.height)/2)
    }
    
		jQuery.each(root.left_children, function(index, child){
	    _r_for_left(child, left_start_left, left_start_top);
	    left_start_top += child.subtree_box_height + R.options.node_vertical_gap;
		})
		
		jQuery.each(root.right_children, function(index, child){
      _r_for_right(child, right_start_left, right_start_top);
      right_start_top += child.subtree_box_height + R.options.node_vertical_gap;
		})
    
  }
	
})