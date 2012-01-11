pie.mindmap = pie.mindmap || {};

// _ch 开头的方法都会导致传入对象的值改变
pie.mindmap.shared_node_methods = {
  _build_title_elm : function(){
    this.title_elm = jQuery('<div></div>')
      .addClass('title')
      .text(this.title);
	}
}

pie.mindmap.node_methods = {
  _build_fd_elm : function(){
    this.fd_elm = jQuery('<div class="fd"></div>')
      .addClass(this.closed ? 'close':'open')

    if(this.children.length == 0){this.fd_elm.hide()}
	},

  // 构造elm
  _build_elm : function(){
    this._build_title_elm();
    this._build_fd_elm();
    this.elm = jQuery('<div class="node"></div>')
      .domdata('id', this.id)
      .append(this.title_elm)
      .append(this.fd_elm)
      .appendTo(this.R.paper_elm);
  },

  // 设置位置，并移动节点
  ch_pos : function(left, top){
    this.left = left;
    this.top  = top;
    this.elm.animate({'left':left, 'top':top}, 800);
	},
	
	// 根据节点折叠与否，返回实际的子树高度
	real_subtree_box_height : function(){
    return this.closed ? this.height : this.subtree_box_height;
	}
}

pie.mindmap.root_methods = {
  // 构造elm
	_build_elm : function(){
    this._build_title_elm();
  
    this.elm = jQuery('<div class="node root"></div>')
      .domdata('id', this.id)
      .append(this.title_elm)
      .appendTo(this.R.paper_elm);
	},
	
  // 所有左侧子节点
  left_children : function(){
    var arr = [];
		jQuery.each(this.children, function(index, child){
		  if('left' == child.pos) arr.push(child);
		})
		return arr;
	},
	
	// 所有右侧子节点
	right_children : function(){
    var arr = [];
    jQuery.each(this.children, function(index, child){
      if('right' == child.pos) arr.push(child);
    })
    return arr;
	},
	
	// 所有左侧子节点显示高度（考虑节点被折叠）
	left_children_boxes_total_height : function(){
	  var children = this.left_children();
    var height = 0;
		jQuery.each(children, function(index, child){
		  height += child.real_subtree_box_height();
		})
		return height + (children.length < 2 ? 0 : (children.length-1)*this.R.options.node_vertical_gap);
	},
	
	// 所有右侧子节点显示高度（考虑节点被折叠）
  right_children_boxes_total_height : function(){
    var children = this.right_children();
    var height = 0;
    jQuery.each(children, function(index, child){
      height += child.real_subtree_box_height();
    })
    return height + (children.length < 2 ? 0 : (children.length-1)*this.R.options.node_vertical_gap);
  }
}

jQuery.extend(pie.mindmap, {

  // 梳理json-object，给每个节点声明以下keys:
	// parent, root, prev_node, next_node
  init_data : function(R){
    var root = R.data;
		
		var _ch_compute_box_size = function(node){
      node.width  = node.elm.outerWidth();
      node.height = node.elm.outerHeight();
		}
		
		var _r = function(node, is_root){
		  node.R = R;
      jQuery.extend(node, pie.mindmap.shared_node_methods);
			
		  if(is_root){
				jQuery.extend(node, pie.mindmap.root_methods);
			}else{
				jQuery.extend(node, pie.mindmap.node_methods);
			}
			
      node._build_elm();
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
		
		_r(root, true);
	}
	
})