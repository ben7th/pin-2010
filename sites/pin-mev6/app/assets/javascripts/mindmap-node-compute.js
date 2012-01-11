pie.mindmap = pie.mindmap || {};

// _ch 开头的方法都会导致传入对象的值改变
pie.mindmap.shared_node_methods = {
  _build_title_elm : function(){
    this.title_elm = jQuery('<div></div>')
      .addClass('title')
      .text(this.title);
	},
	
	recompute_box_size : function(){
    this.width  = this.elm.outerWidth();
    this.height = this.elm.outerHeight();
	},
	
  _util_compute_children_height : function(children){
    var height = 0;
    jQuery.each(children, function(index, child){
      height += child.real_subtree_box_height();
    })
    height += children.length < 2 ? 0 : (children.length-1)*this.R.options.node_vertical_gap;
    return height;
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
    if(this.closed){
		  return this.height;
		}
		
		var _height = this._util_compute_children_height(this.children);
		
		return jQuery.array([this.height, _height]).max();
	},
	
  hide_all_children : function(){
    jQuery.each(this.children, function(index, child){
      this.hide_all_children(child);
      child.elm.hide();
    })
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
    return jQuery.array(this.children).select(function(child){
      return 'left' == child.pos
    })
	},
	
	// 所有右侧子节点
	right_children : function(){
    return jQuery.array(this.children).select(function(child){
		  return 'right' == child.pos
		})
	},
	
	// 所有左侧子节点显示高度（考虑节点被折叠）
	left_children_boxes_total_height : function(){
	  return this._util_compute_children_height(this.left_children());
	},
	
	// 所有右侧子节点显示高度（考虑节点被折叠）
  right_children_boxes_total_height : function(){
    return this._util_compute_children_height(this.left_children());
  }
}

/////////////////

jQuery.extend(pie.mindmap, {

  // 梳理json-object，给每个节点声明以下keys:
	// parent, root, prev_node, next_node
  init_data : function(R){
    var root = R.data;
		
		var _r = function(node, parent_node){
		  node.R = R;
      jQuery.extend(node, pie.mindmap.shared_node_methods);
			
		  if(null == parent_node){
				jQuery.extend(node, pie.mindmap.root_methods);
			}else{
				jQuery.extend(node, pie.mindmap.node_methods);
			}
			
      node._build_elm();
			node.recompute_box_size();

		  node.parent = parent_node;
			node.root   = root;
			
			var children = node.children;
      jQuery.each(children, function(index, child){
        _r(child, node);
				
        child.prev_node = children[index - 1] || null;
        child.next_node = children[index + 1] || null;
      });
		}
		
		_r(root, null);
	}
	
})