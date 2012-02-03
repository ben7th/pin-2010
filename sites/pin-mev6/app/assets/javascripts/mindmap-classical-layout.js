pie.mindmap.classical_layout = {
  shared_methods : {
    _util_compute_children_width : function(children){
      return jQuery.array(children).map(function(child){
        return child.width + child.real_subtree_box_width();
      }).max() + this.R.options.NODE_X_GAP;
    },
    
    _util_compute_children_height : function(children){
      var height = 0;
      jQuery.each(children, function(index, child){
        height += child.real_subtree_box_height();
      })
      return height + (children.length<2 ? 0 : (children.length-1)*this.R.options.NODE_Y_GAP);
    }
  },
  
  root_methods : {
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
    
    // 所有左侧子节点显示宽度
    left_children_boxes_total_width : function(){
      return this._util_compute_children_width(this.left_children());
    },
    
    // 所有左侧子节点显示高度（考虑节点被折叠）
    left_children_boxes_total_height : function(){
      return this._util_compute_children_height(this.left_children());
    },
    
    // 所有右侧子节点显示宽度
    right_children_boxes_total_width : function(){
      return this._util_compute_children_width(this.right_children());
    },
    
    // 所有右侧子节点显示高度（考虑节点被折叠）
    right_children_boxes_total_height : function(){
      return this._util_compute_children_height(this.right_children());
    },
    
    // 当前可见的部分的宽度
    visible_width : function(){
      return this.left_children_boxes_total_width() +
             this.width + 
             this.right_children_boxes_total_width();
    },
    
    // 当前可见的部分的高度
    visible_height : function(){
      return jQuery.array([
        this.left_children_boxes_total_height(),
        this.height,
        this.right_children_boxes_total_height(),
      ]).max();
    },
    
    do_pos_animate : function(){/*..nothing..*/}
  },
  
  node_methods : {
    // 根据节点折叠与否，返回实际的子树宽度
    real_subtree_box_width : function(){
      return this._util_compute_children_width(this.children);
    },
    
    // 根据节点折叠与否，返回实际的子树高度
    // 如果折叠，返回节点盒高度
    // 如果未折叠，返回节点盒和子节点盒中高度较大者
    real_subtree_box_height : function(){
      if(this.closed){ return this.height; }    
      return jQuery.array([this.height, this.children_boxes_total_height()]).max();
    },
    
    // 所有子节点的盒高度之和，包括 Y_GAP
    children_boxes_total_height : function(){
      return this._util_compute_children_height(this.children);
    },
    
    node_box_top_offset : function(){
      var offset = (this.real_subtree_box_height() - this.height)/2;
      return offset > 0 ? offset : 0;
    },
    
    children_box_top_offset : function(){
      var offset = (this.real_subtree_box_height() - this.children_boxes_total_height())/2;
      return offset > 0 ? offset : 0;
    },
    
    // 设置位置，但并不立刻移动节点，所有节点的后续效果交由do_pos_animate函数统一处理
    // animation_flag 节点将发生的展现状态变化，分以下两种：
    //  'show', 'hide'
    //  下一次执行 do_nodes_pos_animate 播放全局动画时，根据 R.next_animation_mode 来确定如何执行动画
    prepare_pos : function(left, top, animation_flag){
      this.old_left = this.left; // 保存旧值，动画中会用到
      this.old_top  = this.top;
      this.old_y_center = this.y_center;
      
      this.left = left;
      this.top  = top;
      this.y_center = top + this.height/2;
      
      this.animation_flag = animation_flag;
    },
    
    // 根据 mode 来确定如何执行动画
    // 调用此方法前必须给上述属性赋值
    // init: show - 动画移动 .8s; hide - 直接隐藏
    do_pos_animate : function(){
      var R = this.R;
      var mode = R.next_animation_mode;
      
      var left = this.left; var move_x = this.left - this.old_left;
      var top  = this.top;  var move_y = this.top  - this.old_top;
      
      if(0 == move_x && 0 == move_y) return;
      
      var elm  = this.elm;
      var canvas_elm = this.canvas_elm;
      var animation_flag = this.animation_flag;
      var is_visible = elm.is(':visible');
      var closed = this.closed;
      
      if('init' == mode){
        var PERIOD = R.options.INIT_ANIMATION_PERIOD; //0.8s default
        
        switch(animation_flag){
          case 'show':{
            elm.animate({'left':left, 'top':top}, PERIOD);
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
        var PERIOD = R.options.RELAYOUT_ANIMATION_PERIOD; //0.4s default
        
        switch(animation_flag){
          case 'show':{
            if(is_visible){
              // 如果本来就看得见，则只是移动
              elm.stop().animate({'left':left, 'top':top}, PERIOD);
              //elm.css({'left':left, 'top':top});
              canvas_elm.animate({'left':'+='+move_x, 'top':'+='+move_y}, PERIOD);
            }else{
              // 如果本来看不见，则渐现
              elm.show().css('opacity',0).animate({'left':left, 'top':top, 'opacity':1}, PERIOD);
              //elm.show().css({'left':left, 'top':top});
              if(!closed) canvas_elm.delay(PERIOD).fadeIn(PERIOD);
            }
            break;
          }
          case 'hide':{
            if(is_visible){
              // 如果本来看得见，渐隐
              elm.delay(R._ani_delay).animate({'left':left, 'top':top, 'opacity':0}, PERIOD, function(){elm.hide()});
              //canvas_elm.fadeOut(PERIOD);
              canvas_elm.hide();
              //elm.hide().css({'left':left, 'top':top});
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
    
    is_left : function(){
      var node = this;
      while(null !=  node.parent.parent){
        node = node.parent;
      }
      return 'left' == node.pos;
    }
    
  },
  
  init : function(R){
    var LAYOUT = pie.mindmap.classical_layout;
    
    /* 喵~ 这就是经典布局的节点排布函数乐~~
     * 经典布局将一级子节点（first_level_nodes）排布在root节点的左右两侧，均匀地树状展开
     */
    
    LAYOUT.init_paper(R, true);
    LAYOUT.set_nodes_positions(R);
    R.next_animation_mode = 'init';
    LAYOUT.do_nodes_pos_animate(R);
  },
  
  init_paper : function(R, is_first_time_load){
    var root = R.data;
    
    var left_children_boxes_total_width  = root.left_children_boxes_total_width();
    
    // 求出导图可见部分的高度和宽度
    // 设置paper_elm尺寸，根据导图大小乘以一个常数来决定
    var visible_height = root.visible_height();
    var visible_width = root.visible_width();
    
    var paper_height = visible_height * 20;
    var paper_width  = visible_width  * 20;
    
    var root_y_off = (visible_height - root.height)/2;
    // 以上纯计算

    if(is_first_time_load){
      // 设置导图的中心点相对画布的偏移量，在经典布局下，导图中心点就是根节点的左上角
      // 之所导图中心点不对正根节点的中心点，是因为根节点改变大小时，左上角的位置是固定不变的
      // 这样比较好处理
      // 这个只设置一次，一般不改了
      
      // 设置paper的宽高和位置
      R.paper_elm.css({
        'width'  : paper_width,
        'height' : paper_height,
        'left'   : paper_width, 
        'top'    : paper_height
      });
      
      // 设置board的scroll值，以保证root显示在正中心
      R.board_elm
        .scrollLeft(paper_width  + root.width /2 - R.board_elm.width() /2)
        .scrollTop( paper_height + root.height/2 - R.board_elm.height()/2);    
    }
  },
  
  set_nodes_positions : function(R){
    var root  = R.data;
    var X_GAP = R.options.NODE_X_GAP;
    var Y_GAP = R.options.NODE_Y_GAP;
    
    var _r = function(node, left, top, is_left){      
      var elm = node.elm.addClass(is_left ? 'left' : 'right');
      
      var real_left = is_left ? left-node.width : left;
      
      if(node.closed){
        node.each_houdai(function(child){
          var n_top = top - (child.height - node.height) / 2;
          child.prepare_pos(real_left, n_top, 'hide');
        })
        node.prepare_pos(real_left, top, 'show');
        return;
      }
      
      var _tmp_height = node.children_box_top_offset();
      jQuery.each(node.children, function(index, child){
        var new_left = is_left ? left - node.width - X_GAP : left + node.width + X_GAP;
        var new_top  = top + _tmp_height;
        _r(child, new_left, new_top, is_left);
        _tmp_height += child.real_subtree_box_height() + Y_GAP;
      })
      
      node.prepare_pos(real_left, top + node.node_box_top_offset(), 'show');
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
      child.elm.addClass(pos);
      _r(child, origin[pos].left, origin[pos].top, child.is_left());
      origin[pos].top += child.real_subtree_box_height() + Y_GAP;
    });
  },
  
  do_nodes_pos_animate : function(R){
    if(null == R.next_animation_mode){
      throw 'YOU MUST SET R.next_animation_mode VALUE BEFORE CALL do_nodes_pos_animate()';
    }
    
    R.each_do(function(node){
      node.do_pos_animate();
      
      // SEE pie.mindmap.folding
      if(!!node.will_redraw_self_line){
        node.draw_self_lines();
        node.will_redraw_self_line = false;
      }
      
      if(!!node.will_redraw_subtree_line){
        node.draw_subtree_lines(true);
        node.will_redraw_subtree_line = false;
      }
    })
    
    R.next_animation_mode = null;
  }
}