pie.mindmap = pie.mindmap || {};

// 与构造节点dom有关的函数
pie.mindmap.shared_node_elm_building_methods = {
  // 文字标题
  _build_title_elm : function(){
    var title_html = jQuery.string(this.title).escapeHTML().str
		  .replace(/\n/g, "<br/>")
			.replace(/\s/g, "&nbsp;")
			.replace(/>$/,  ">&nbsp;");
		
    this.title_elm = jQuery('<div class="title"></div>')
      .html(title_html);
      
    if(null != this.image){
		  this.title_elm.css('margin-left', this.image.width);
		}
	},
	
	// 图片
	_build_image_elm : function(){
    if(null == this.image){
		  this.image_elm = null;
		  return;
		}
		
	  this.image_elm = jQuery('<div class="image"><div class="box"></div></div>')
		  .domdata('src', this.image.url)
			.domdata('attach-id', this.image.attach_id)
			.css({'width':this.image.width, 'height':this.image.height})
	}
}

// _ch 开头的方法都会导致传入对象的值改变
pie.mindmap.shared_node_computing_methods = {
	
	recompute_box_size : function(){
    this.width  = this.elm.outerWidth();
    this.height = this.elm.outerHeight();
    
    if(null != this.image){
      var title_height = this.title_elm.height();
      if(title_height < this.image.height){
        this.title_elm.css('margin-top', (this.image.height - title_height)/2);
      }
    }
	},
	
  _util_compute_children_height : function(children){
    var height = 0;
    jQuery.each(children, function(index, child){
      height += child.real_subtree_box_height();
    })
    return height + (children.length<2 ? 0 : (children.length-1)*this.R.options.NODE_Y_GAP);
  },
  
  _util_compute_children_width : function(children){
    return jQuery.array(children).map(function(child){
      return child.width + child.real_subtree_box_width();
    }).max() + this.R.options.NODE_X_GAP;
  }
}

pie.mindmap.node_methods = {
  _build_fd_elm : function(){
    this.fd_elm = jQuery('<div class="fd"></div>')
      .addClass(this.closed ? 'close':'open')

    if(0 == this.children.length){this.fd_elm.hide()}
	},

  // 构造elm
  _build_elm : function(){
    this._build_title_elm();
    this._build_fd_elm();
		this._build_image_elm();
		
    this.elm = jQuery('<div class="node"></div>')
      .domdata('id', this.id)
      .append(this.title_elm.css('color', this.textcolor))
      .append(this.fd_elm)
			.prepend(this.image_elm)
			.css('background-color', this.bgcolor)
      .appendTo(this.R.paper_elm);
  },

  // 设置位置，并移动节点
  ch_pos : function(left, top){
    this.left = left;
    this.top  = top;
    this.elm.animate({'left':left, 'top':top}, 800);
    //this.elm.css({'left':left, 'top':top})
    
    this.y_center = this.top + this.height/2;
	},
	
	// 所有子节点的盒高度之和，包括 Y_GAP
	children_boxes_total_height : function(){
    return this._util_compute_children_height(this.children);
	},
	
	// 根据节点折叠与否，返回实际的子树高度
	// 如果折叠，返回节点盒高度
	// 如果未折叠，返回节点盒和子节点盒中高度较大者
	real_subtree_box_height : function(){
    if(this.closed){ return this.height; }		
		return jQuery.array([this.height, this.children_boxes_total_height()]).max();
	},
	
	// 根据节点折叠与否，返回实际的子树宽度
	real_subtree_box_width : function(){
    return this._util_compute_children_width(this.children);
	},
	
	node_box_top_offset : function(){
    var offset = (this.real_subtree_box_height() - this.height)/2;
		return offset > 0 ? offset : 0;
	},
	
	children_box_top_offset : function(){
    var offset = (this.real_subtree_box_height() - this.children_boxes_total_height())/2;
		return offset > 0 ? offset : 0;
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
		this._build_image_elm();
  
    this.elm = jQuery('<div class="node root"></div>')
      .domdata('id', this.id)
      .append(this.title_elm.css('color', this.textcolor))
			.prepend(this.image_elm)
      .css('background-color', this.bgcolor)
      .appendTo(this.R.paper_elm);
	},
	
  // 所有左侧子节点
  left_children : function(){
    return jQuery.array(this.children).select(function(child){
      return 'left' == child.pos
    }).arr;
	},
	
	// 所有右侧子节点
	right_children : function(){
    return jQuery.array(this.children).select(function(child){
		  return 'right' == child.pos
		}).arr;
	},
	
	// 所有左侧子节点显示高度（考虑节点被折叠）
	left_children_boxes_total_height : function(){
	  return this._util_compute_children_height(this.left_children());
	},
	
	// 所有右侧子节点显示高度（考虑节点被折叠）
  right_children_boxes_total_height : function(){
    return this._util_compute_children_height(this.right_children());
  },
  
  // 所有左侧子节点显示宽度
  left_children_boxes_total_width : function(){
    return this._util_compute_children_width(this.left_children());
  },
  
  // 所有右侧子节点显示宽度
  right_children_boxes_total_width : function(){
    return this._util_compute_children_width(this.right_children());
  }
  
}

/////////////////

jQuery.extend(pie.mindmap, {

  // 梳理json-object，给每个节点声明以下keys:
	// parent, root, prev_node, next_node
  init_data : function(R){
    var root = R.data;
		
    // 递归生成节点doms ，并排布
		var _r = function(node, parent_node){
		  node.R = R;
		  jQuery.extend(node, pie.mindmap.shared_node_elm_building_methods);
      jQuery.extend(node, pie.mindmap.shared_node_computing_methods);
			
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
		
		// 加载图片
		jQuery(R.paper_elm).find('.node .image').each(function(){
      var elm = jQuery(this);
      pie.load_cut_img(elm.data('src'), elm, elm.find('.box'));
      elm.addClass('-img-loaded-');
		})
		
		// 绑定图片事件 绑定事件 live 需用 R.board_elm
		jQuery(R.board_elm).find('.node .image').live('click', function(){
		  var elm = jQuery(this);
		  pie.log(elm.data('src'));
		})
	}
	
})