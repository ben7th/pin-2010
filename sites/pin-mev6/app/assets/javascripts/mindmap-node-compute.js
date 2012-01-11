pie.mindmap = pie.mindmap || {};

// _ch 开头的方法都会导致传入对象的值改变

jQuery.extend(pie.mindmap, {

  // 梳理json-object，给每个节点声明以下keys:
	// parent, root, prev_node, next_node
  init_data : function(R){
    var root = R.data;
		
		var _ch_build_node_elm = function(node){
      node.elm = jQuery('<div></div>')
        .addClass('node')
        .text(node.title)
        .appendTo(R.paper_elm);
		}
		
		var _ch_compute_box_size = function(node){
      node.width  = node.elm.outerWidth();
      node.height = node.elm.outerHeight();
		}
		
		var _r = function(node, parent){
			_ch_build_node_elm(node);
			_ch_compute_box_size(node);

		
		  node.parent = parent;
			node.root   = root;
			
			var children = node.children;
			var total_children_height = 0;
			var children_boxes_widths = [0]
      jQuery.each(children, function(index, child){
        _r(child);
				
        child.prev_node = children[index - 1] || null;
        child.next_node = children[index + 1] || null;
				
				total_children_height += child.subtree_box_height;
				children_boxes_widths.push(child.subtree_box_width);
      });
			
			total_children_height += children.length < 2 ? 0 : (children.length-1)*R.options.node_vertical_gap;
			
			node.subtree_box_height = jQuery.array([node.height, total_children_height]).max();
			node.subtree_box_width = node.width + jQuery.array(children_boxes_widths).max();
			
		}
		
		_r(root, null);
	}
	
})
