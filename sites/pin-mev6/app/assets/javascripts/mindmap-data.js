pie.mindmap = pie.mindmap || {};

// 与构造节点dom有关的函数
pie.mindmap.shared_node_elm_building_methods = {
  is_note_blank : function(){
    return jQuery.string(this.note).blank();
  },
  
  // 文字标题
  _build_title_elm : function(){
    var title_html = jQuery.string(this.title).escapeHTML().str
		  .replace(/\n/g, "<br/>")
			.replace(/\s/g, "&nbsp;")
			.replace(/>$/,  ">&nbsp;");
		
    this.title_elm = jQuery('<div class="title"></div>')
      .html(title_html)
      .css('color', this.textcolor);
      
    if(null != this.image){
		  this.title_elm.css('margin-left', this.image.width);
		}
		
		if(!this.is_note_blank()){
		  this.title_elm.css('margin-right', 18);
		}
	},
	
	// 图片
	_build_image_elm : function(){
    if(null == this.image){
		  this.image_elm = null;
		  return;
		}
		
	  this.image_elm = jQuery('<a class="image" href="javascript:;" title="点击查看大图"><div class="box"></div></a>')
		  .domdata('src', this.image.url)
			.domdata('attach-id', this.image.attach_id)
			.css({'width':this.image.width, 'height':this.image.height})
  },
  
  // 备注
  _build_note_elm : function(){
    if(this.is_note_blank()){
      this.note_elm = null;
      return;
    }
    
    this.note_elm = jQuery('<a class="note" href="javascript:;" title="点击查看备注"></a>')
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
		this._build_note_elm();
		
    this.elm = jQuery('<div class="node"></div>')
      .domdata('id', this.id)
			.append(this.image_elm)
      .append(this.title_elm)
      .append(this.note_elm)
      .append(this.fd_elm)
			.css('background-color', this.bgcolor)
      .appendTo(this.R.paper_elm);
  },

  // 设置位置，但并不立刻移动节点，所有节点的后续效果交由do_pos_animate函数统一处理
  // animation_flag 节点将发生的展现状态变化，分以下两种：
  //  'show', 'hide'
  //  下一次执行 do_nodes_pos_animate 播放全局动画时，根据 R.next_animation_mode 来确定如何执行动画
  prepare_pos : function(left, top, animation_flag){
    this.old_left = this.left; // 保存旧值，动画中会用到
    this.old_top  = this.top;
    this.left = left;
    this.top  = top;
    this.y_center = this.top + this.height/2;
    this.animation_flag = animation_flag;
	},
	
	// 根据 mode 来确定如何执行动画
	// 调用此方法前必须给上述属性赋值
	// init: show - 动画移动 .8s; hide - 直接隐藏
	do_pos_animate : function(mode){
	  var left = this.left;
	  var top  = this.top;
	  var elm  = this.elm;
	  var animation_flag = this.animation_flag;
	  var is_visible = elm.is(':visible');
	  var R = this.R;
	  
	  if(left == this.old_left && top == this.old_top) return;
	  
	  if('init' == mode){
  	  switch(animation_flag){
  	    case 'show':{
  	      elm.animate({'left':left, 'top':top}, R.options.INIT_ANIMATION_PERIOD);
  	      break;
  	    }
  	    case 'hide':{
  	      elm.hide()
  	        .css({'left':left, 'top':top});
  	      break;
  	    }
  	  }
  	  return; 
	  }
	  
	  if('folding' == mode){
	    var RELAYOUT_ANIMATION_PERIOD = R.options.RELAYOUT_ANIMATION_PERIOD;
	    
  	  switch(animation_flag){
  	    case 'show':{
  	      if(is_visible){
  	        // 如果本来就看得见，则只是移动
  	        elm.stop().animate({'left':left, 'top':top}, RELAYOUT_ANIMATION_PERIOD);
	        }else{
	          // 如果本来看不见，则渐现
	          elm.show().css('opacity',0).animate({'left':left, 'top':top, 'opacity':1}, RELAYOUT_ANIMATION_PERIOD);
	        }
	        break;
  	    }
  	    case 'hide':{
  	      if(is_visible){
  	        // 如果本来看得见，渐隐
  	        elm.animate({'left':left, 'top':top, 'opacity':0}, RELAYOUT_ANIMATION_PERIOD, function(){elm.hide()});
  	      }else{
  	        // 如果本来看不见，则只是修改属性
  	        elm.css({'left':left, 'top':top});
	        }
	        break;
  	    }
  	  }
  	  return; 
	  }
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
  },
  
  // descendants 这个单词太难记了
  houdai : function(){
    var re = [];
    jQuery.each(this.children, function(index, child){
      re = re.concat([child]).concat(child.houdai());
    });
    return re;
  },
  
  toggle_closed : function(){
    var left = this.left;
    var top  = this.top; var height = this.height;
    
    if(this.closed){
      this.fd_elm.removeClass('close').addClass('open');
      this.closed = false;
	  }else{
	    this.fd_elm.removeClass('open').addClass('close');
	    this.closed = true;
	  }
	  
    pie.mindmap.do_relayout_classical(this.R, 'folding');
  }
}

pie.mindmap.root_methods = {
  // 构造elm
	_build_elm : function(){
    this._build_title_elm();
		this._build_image_elm();
  
    this.elm = jQuery('<div class="node root"></div>')
      .domdata('id', this.id)
      .append(this.image_elm)
      .append(this.title_elm)
      .append(this.note_elm)
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
  },
  
  // 当前可见的部分的高度
  visible_height : function(){
    return jQuery.array([
		  this.left_children_boxes_total_height(),
		  this.height,
		  this.right_children_boxes_total_height(),
		]).max();
  },
  
  // 当前可见的部分的宽度
  visible_width : function(){
    return this.left_children_boxes_total_width() +
  	       this.width + 
  	       this.right_children_boxes_total_width();
  }
}

/////////////////

jQuery.extend(pie.mindmap, {

  // 梳理json-object，给每个节点声明以下keys:
	// parent, root, prev_node, next_node
  init_data : function(R){
    var root = R.data;
		
    R.get = function(node_id){
      return R.data_kv[node_id];
    }
    
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
			
			R.data_kv[node.id] = node;
			
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
		});
		
		/////////////////////////////////////////////////////////////////////////////////
		
		// 绑定图片事件 绑定事件 live 需用 R.board_elm
		jQuery(R.board_elm).find('.node .image').live('click', function(){
		  var elm = jQuery(this);
		  R.show_overlay();
		  
		  var node_id = elm.closest('.node').data('id');
		  var node = R.get(node_id);
		  var _title = (null == node) ? '' : node.title;
		  
		  var init_img_width  = 250;
		  var init_img_height = init_img_width * 0.75;
		  
		  var box_elm = jQuery('<div class="box"></div>')
		    .css({'height':init_img_height, 'width':init_img_width})
		  
		  // 载入图片，并动态调整宽高
		  var load_img = function(){  
  		  var full_image_src = node.image.url.replace('/thumb/','/original/');
  	    var img_elm = jQuery('<img style="display:none;" src="'+full_image_src+'" />');
  	    box_elm.append(img_elm);
        img_elm.bind('load',function(){
          img_elm.fadeIn(500);
          
          var iw = img_elm.width();
          var ih = img_elm.height();
          
          //img_elm.css({
          //  'margin-left' : - iw / 2,
          //  'margin-top'  : - ih / 2
          //})
          
          var w1, h1;
          var max_width = 640; var max_height = 480; var _min = 200;
          //step 1 最大宽度640，如果超过则调整比例，使得宽度适应外框
          if(iw > max_width){w1 = max_width; h1 = ih * max_width / iw;}
          else{w1 = iw; h1 = ih;}
          
          var box_w = w1; var box_h = h1;
          var ml = 0; var mt = 0;
          
          //step 2 计算margin
          if(w1 < _min){
            box_w = _min;
            ml = (_min - w1)/2;
          }
          
          if(h1 < _min){
            box_h = _min;
            mt = (_min - h1)/2;
          }
          
          if(h1 > max_height){
            box_h = max_height;
            //mt = (max_height - h1)/2;
          }
          img_elm.css({
            'margin-left' : ml,
            'margin-top'  : mt,
            'width'  : w1,
            'height' : h1
          });
          box_elm.animate({
            'width'  : [box_w, 'easeOutSine'],
            'height' : [box_h, 'easeOutSine']
          },200);
          R.image_lightbox_elm.animate({
            'margin-left' : [- (box_w / 2 + 10), 'easeOutSine'],
            'margin-top'  : [- (box_h / 2 + 50), 'easeOutSine']
          },200);
                      
        })
		  }
		    
		  R.image_lightbox_elm = jQuery('<div class="image-lightbox"></div>')
		    .append(box_elm)
		    .append(jQuery('<div class="title"></div>').text(_title))
		    .append(jQuery('<a class="close" href="javascript:;" title="关闭"></a>'))
		    //.append(jQuery('<a class="prev" href="javascript:;" title="上一个"></a>'))
		    //.append(jQuery('<a class="next" href="javascript:;" title="下一个"></a>'))
		    .hide().delay(300).fadeIn(400, load_img)
		    //.delay(200).animate({'top': init_top})
		    .appendTo(R.overlay_elm);
		    
		  R.image_lightbox_elm
		    .css('margin-left', -  (init_img_width / 2 + 10))
		    .css('margin-top',  - (init_img_height / 2 + 50))
		    .data('node-id', node_id);
		});
		
		jQuery('.image-lightbox a.close').live('click', function(){
		  R.image_lightbox_elm.fadeOut(400, function(){
		    R.hide_overlay();
		  });
		})
		
		//TODO 上一个，下一个稍后实现
		
		//jQuery('.image-lightbox a.prev').live('click', function(){
		//  var current_node = R.image_lightbox_elm.data('node-id');
		//})
		
		////////////////////////////////////////////////////////////////////////////
		
		// 绑定折叠展开事件
		jQuery(R.board_elm).find('.node .fd').live('click', function(){
		  var elm = jQuery(this);
		  
		  var node_id = elm.closest('.node').data('id');
		  var node = R.get(node_id);
		  
		  node.toggle_closed();
		})
		
		////////////////////////////////////////////////////////////////////
		
		R.show_overlay = function(){
		  if(null != R.overlay_elm){ return; }
		  
		  R.overlay_elm = jQuery('<div class="overlay"></div>')
		    .hide().fadeIn(300);
		    
		  R.board_elm.after(R.overlay_elm);
		}
		
		R.hide_overlay = function(){
		  if(null == R.overlay_elm){ return; }
		  
		  R.overlay_elm.fadeOut(300,function(){
		    R.overlay_elm.remove();
		    R.overlay_elm = null;
		  })
		}
	}
})