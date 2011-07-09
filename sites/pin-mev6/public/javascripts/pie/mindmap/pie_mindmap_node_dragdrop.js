/*
 * 用于处理导图节点拖拽的函数
 **/
pie.drag.PinNode=Class.create(pie.drag.Base,{
	onInit:function(){
		this.node               = this.el;
		this.el                 = this.node.el;
		this.node.dragflag      = false;
    this.map_root           = this.node.root;
		this.map                = this.node.map;
		this.effective_distance = 200;
	},
	isReady:function(){
		return !(this.evtel.tagName=="INPUT"||this.evtel.tagName=="TEXTAREA");
	},
	beforeStart: function(){
    this.map.stop_edit_focus_title();
    var dragproxy = this.__init_dragproxy();

		//拖拽代理作为paper的直接子节点
		this.map.paper.jq.append(dragproxy);
		this.map.ondrag = this.node;

		this.ileft = parseInt(dragproxy.style.left||0);
		this.itop = parseInt(dragproxy.style.top||0);
	},

  __init_dragproxy:function(){
    this.__build_dragproxy();
    this.__set_drag_proxy_style();
    this.dragproxy.update(this.node.nodetitle.el.innerHTML);
    return this.dragproxy;
  },

  __build_dragproxy:function(){
		if (!this.dragproxy) {
			this.dragproxy = $(Builder.node('div', {
				'class': 'node',
				'style': "position:absolute; border:solid 3px; padding:2px 3px;"
			}));
		}
  },

  __set_drag_proxy_style:function(){
    this.scrolleroffset = this.map.scroller.jq.offset();
		var off2 = this.el.cumulativeOffset();

		this.dragproxy.setStyle({
			left:(off2.left - this.scrolleroffset.left)+'px',
			top:(off2.top - this.scrolleroffset.top)+'px',
			width:this.node.width-12+"px",
			height:this.node.height-5+"px",
			opacity:0.5,
			zIndex:103,
			display:'none'
		});
  },

  /*好，开始拖拽了*/
	onDragging:function(){
		this.node.dragflag = true;

    this.__update_dragproxy_pos();

		$(this.node.nodetitle.el).addClassName('quiet')

		var map = this.map;
		var scroller_jq = map.scroller.jq;

		var x = this.newX + scroller_jq.scrollLeft() - this.scrolleroffset.left;
		var y = this.newY + scroller_jq.scrollTop() - this.scrolleroffset.top - 10;
    // 解释下 10 = selected node's (border + padding)*2

    this.__clear_droptarget();

		//读取posRegister，实时判断拖拽目标
		map.posRegister.each(function(pair){
      var value = pair.value;
			this.looping_node = value[0];
			var left = value[1];
			var top = value[2] - 5; //5px 是两同级节点间隔的一半;
			var right = value[3];
			var bottom = value[4] + 5;

			var x_mid = (left + right)/2;

			this.is_drop_on_right = this.__is_drop_on_right(x, x_mid);
			this.looping_children = this.__get_looping_children();

			if(!this.__can_be_drop(x, x_mid)) return;

      var in_effective_area = (x-x_mid).abs() < this.effective_distance && y>top && y<=bottom;
      
      if(0 == this.looping_children.length){
        //根结点：没有右/左侧一级子节点
        //一般节点：没有子节点
        if(in_effective_area){
          this.__ready_to_drop_on_as_new_child();
          throw $break;
        }
        //放在根结点上 或者作为浮动
        this.__ready_to_drop_on_root();
        return;
      }
      
      if(this.looping_node.closed){
        //如果节点是折叠状态
        if(in_effective_area){
          this.__ready_to_drop_on_as_one_of_children();
          throw $break;
        }
        //放在根结点上 或者作为浮动
        this.__ready_to_drop_on_root();
        return;
      }

      var dropped = false;
      this.looping_children.each(function(child){
        this.looping_child = child;
        var child_value = map.posRegister.get(child.id);
        var child_left = child_value[1];
        var child_top = child_value[2] - 5; //5px 是两同级节点间隔的一半
        var child_right = child_value[3];
        var child_bottom = child_value[4] + 5;

        var child_y_mid = (child_top + child_bottom)/2;
        var child_x_mid = (child_left + child_right)/2;

        var child_effective_distance = (child_x_mid - x_mid).abs();

        var in_child_effective_area = (x-x_mid).abs() < child_effective_distance && y>child_top && y <= child_bottom;

        if(in_child_effective_area){
          if (y < child_y_mid) {
            //被拖拽点作为node的哥哥节点
            this.__ready_to_drop_on_as_older_brother();
            dropped = true;
            throw $break;
          }else{
            //被拖拽点作为node的弟弟节点 //此处如果不是根结点，可以优化，不过目前来说意义不大
            this.__ready_to_drop_on_as_younger_brother();
            dropped = true;
            throw $break;
          }
        }
      }.bind(this));
      if(dropped) throw $break;
		}.bind(this));
	},

  __update_dragproxy_pos:function(){
    var newLeft = this.ileft + this.distanceX;
    var newTop = this.itop + this.distanceY;

		this.dragproxy.setStyle({
			left:newLeft+'px',
			top:newTop+'px',
			display:''
		});
  },

  __clear_droptarget:function(){
		if (this.droptarget != null) {
			this.droptarget.el.removeClassName('dropon');
			this.dropbox.hide();
			this.dropcanvas.hide();
		}
		this.droptarget = null;
  },

  //判断现在鼠标是否位于目标节点右边
  __is_drop_on_right:function(x, x_mid){
    var node = this.looping_node;
    if(node == this.map_root){
      // 如果目标节点是根节点，则判断是否位于中线右边
      return x >= x_mid;
    }else{
      // 如果目标节点是普通节点，则判断一下目标节点的方位即可
      // 因为目标节点在右方的话，节点只可能插入其右方（这句话绕吧）
      return node.sub.put_on_right();
    }
  },

  //获取可能被作为兄弟节点的子节点列表
  __get_looping_children:function(){
    var node = this.looping_node;
    var children = node.children;
    if(node == this.map_root){
      return this.is_drop_on_right ?
        children.select(function(c){return c.put_on_right();})
        :
        children.select(function(c){return !c.put_on_right();})
    }else{
      return children;
    }
  },

  __can_be_drop:function(x, x_mid){
    var node = this.looping_node;
    return (this.is_drop_on_right ? x>x_mid : x<x_mid) || node == this.map_root
  },

  __ready_to_drop_on_as_new_child:function(){
    this.droptarget = this.looping_node;
    this.dropindex = null;
    this._show_drop_target_tip();
  },

  __ready_to_drop_on_as_one_of_children:function(){
    var node = this.looping_node;
    this.droptarget = node;
    this.dropindex = node.children.last().index + 1;
    this._show_drop_target_tip();
  },

  __ready_to_drop_on_root:function(){
    /*还未实现*/
  },

  __ready_to_drop_on_as_older_brother:function(){
    this.droptarget = this.looping_node;
    this.dropindex = this.looping_child.index;
    this._show_drop_target_tip();
  },

  __ready_to_drop_on_as_younger_brother:function(){
    var node = this.looping_node;
    var arr = this.looping_children;
    var subindex = arr.indexOf(this.looping_child);
    var nextsub = arr[subindex+1];
    this.droptarget = node;
    this.dropindex = nextsub==null ? node.children.length : nextsub.index;
    this._show_drop_target_tip();
  },

  /*拖拽结束啦！*/
	beforeFinish:function(){
		if (this.droptarget != null) {
			//处理拖拽到节点上的情况
			this.droponNode();
			//清除对象以及样式
			this.droptarget.el.removeClassName('dropon');
			this.droptarget = null;
			this.dropbox.hide();
			this.dropcanvas.hide();
		}

		if(this.el.dragflag) {
			this.el.dragflag = false;
			this.map.ondrag={};
		}

		this.dragproxy.remove();

		$(this.node.nodetitle.el).removeClassName('quiet')
	},
  
	droponNode:function(){
		var droptarget = this.droptarget;

    if(this.__is_target_cannot_be_drop_on()) return;

    this.__remove_node_from_node_s_parent_s_children();
    this.__add_node_to_target_as_a_child();
    
    this.node.pos = this.is_drop_on_right ? 'right' : 'left';

    this.node.__changesub(droptarget == this.map_root ? this.node : droptarget.sub);
    
    this.__show_children_doms_of_droptarget();
    this.__do_save_map();

		//如果父节点不在折叠状态，则选中被拖拽节点，否则选中父节点
		if(this.node.parent.closed) this.node.parent._expand();
		
		this.map.reRank();
		this.node.select();
	},

  __do_save_map:function(){
		var record = this.map.opFactory.getMoveInstance(this.node);
		this.map._save(record);
  },

  __remove_node_from_node_s_parent_s_children:function(){
		var old_parent = this.___remove_node_from_parent_s_children_array();
    this.___hide_doms_if_node_has_no_child(old_parent);
    this.___hide_node_branch_doms_of_root(old_parent)
    return old_parent;
  },

  ___remove_node_from_parent_s_children_array:function(){
    var node = this.node;
    var parent = node.parent;
		parent.children = parent.children.without(node);
		parent.__tidyChildren();

    return parent;
  },

  ___hide_doms_if_node_has_no_child:function(node){
		if (0 == node.children.length) {
			node.folder.el.hide();
			node.content.el.hide();
		}
  },

  ___hide_node_branch_doms_of_root:function(old_parent){
		if (old_parent == this.map_root) {
			this.node.branch.el.remove();
			this.node.branch.el=null;
			this.node.canvas.el.remove();
			this.node.canvas.el=null;
			this.node.container.el.style.left="";
		}
  },

  __add_node_to_target_as_a_child:function(){

    var droptarget = this.droptarget;
    var index = this.dropindex;
    var children = droptarget.children;

		//如果拖拽目标恰好是被拖拽节点的父节点，且index>被拖拽节点的index 则index--;
		if(this.node.parent == droptarget && index > this.node.index) index--;

		var part1 = children.slice(0, index);
		var part2 = children.slice(index);
		part1.push(this.node);
		droptarget.children = part1.concat(part2);
    
		this.node.parent = droptarget;
		droptarget.__tidyChildren();
  },

  __show_children_doms_of_droptarget:function(){
    var dt = this.droptarget;
		dt.folder.el.show();
		dt.content.el.show();
		dt.content.el.appendChild(this.node.container.el);
  },

  /*显示拖拽提示dom*/
	_show_drop_target_tip:function(){

		this.__build_dropbox();

		var map = this.map;
		var droptarget = this.droptarget;
		var index = this.dropindex;
		var is_drop_on_root = droptarget == this.map_root;

    if(this.__is_target_cannot_be_drop_on()) return;

		var node_pos = map.posRegister.get(droptarget.id);
		var left = 0;
		var top = 0;

		if(is_drop_on_root){
			left = this.is_drop_on_right ? node_pos[3] + 40 : node_pos[1] - 120;
			if (index == null){
				top = node_pos[4] -28 + 2;
			}else{
				if(index < droptarget.children.length){
					top = map.posRegister.get(droptarget.children[index].id)[2] - 10;
				}else{
					top = this.is_drop_on_right ?
					map.posRegister.get(droptarget.children.select(function(c){return c.put_on_right()}).last().id)[4] - 5
					:
					map.posRegister.get(droptarget.children.select(function(c){return !c.put_on_right()}).last().id)[4] - 5;
				}
			}
			this.__put_dropbox(left,top);
		}else{
			if(index==null) index=0;
			if (this.is_drop_on_right) {
				left = node_pos[3] + 10;
			}else{
				left = node_pos[1] - 90;
			}
			if(droptarget.children.length == 0){
				top = node_pos[4] - 20 + 2;
			}else{
				if(droptarget.closed){
					//如果该节点被折叠
					top = node_pos[4] - 20;
				}else{
					if(index < droptarget.children.length){
						top = map.posRegister.get(droptarget.children[index].id)[2] - 10;
					}else{
						top = map.posRegister.get(droptarget.children.last().id)[4] - 5;
					}
				}
			}
			this.__put_dropbox(left,top);
		}

		//以下为画线
		var node_base_x = (is_drop_on_root)?(node_pos[1] + node_pos[3])/2:node_pos[3];
		var node_base_y = (is_drop_on_root)?(node_pos[2] + node_pos[4])/2:droptarget.canvas.top + droptarget.sub.container.top + this.map_root.posY;

		var canvas_top = [top,node_base_y].min();
		var canvas_height = (is_drop_on_root)?[node_base_y-top , (top+20)-node_base_y].max():[(node_base_y+droptarget.height)-top , (top + 20)-node_base_y].max();
		var canvas_left = [node_base_x,left+80].min();
		var canvas_width = (is_drop_on_root)?[left-node_base_x , node_base_x-(left+80)].max():10;

		this.dropcanvas.setStyle({
			left:canvas_left+'px',
			top:canvas_top+'px',
			width:canvas_width+'px',
			height:canvas_height.abs()+'px',
			zIndex: (is_drop_on_root)?"100":"103",
			border: "solid 0px",
			display:''
		});

    this.dropcanvas.setAttribute("width", canvas_width);
    this.dropcanvas.setAttribute("height", canvas_height.abs());
    map.__prepare_canvas_for_ie();

		this.dropcanvas = $(this.dropcanvas.id); // excanvas会替换对象，导致原有的引用失效
    
		var ctx = this.dropcanvas.getContext('2d');
		ctx.fillStyle="#F56F00";
		ctx.strokeStyle="#F56F00";
    ctx.beginPath();

		if (droptarget.children.length == 0) {
			ctx.moveTo(0, canvas_height.abs() - 10);
			ctx.lineTo(canvas_width, canvas_height.abs() - 10);
		}else{
			var x1 = this.is_drop_on_right ? 0 : canvas_width;
			var x2 = this.is_drop_on_right ? canvas_width : 0;
			var y1 = is_drop_on_root ? node_base_y - canvas_top : node_base_y + droptarget.height - 10 - canvas_top;
			var y2 = top + 10 - canvas_top;
			ctx.moveTo(x1, y1);
			ctx.lineTo(x2, y2);
		}
    
		ctx.stroke();

		//标记出drop目标
		droptarget.el.addClassName('dropon');
	},

  __is_target_cannot_be_drop_on:function(){
    //如果节点被试图放置在自身的子节点上，不通过
		var p = this.droptarget;
    var root = this.map_root;
		while(p != root){
			if(this.node == p) return true;
			p = p.parent;
		}
    
    var droptarget = this.droptarget;
    var index = this.dropindex;
		if(droptarget == this.node.parent){
      if(droptarget == root){
        if(this.node.pos == this.is_drop_on_right ? 'right' : 'left'){
          return index == this.node.index || index == this.node.index + 1;
        }
      }else{
        //如果某个节点试图被放在自身附近（index不变或+1），不通过
        return index == this.node.index || index == this.node.index + 1;
      }
    }
    return false;
  },
  
	__build_dropbox:function(){
		var map = this.map;
		if(!this.dropbox){
			this.dropbox=$(Builder.node('div',{
				id:'mindmap_dropbox',
				'style':"position:absolute;background-color:#F56F00;-moz-border-radius:4px;-webkit-border-radius:4px;"
			}));
			this.dropcanvas=$(Builder.node("canvas", {
				id: 'mindmap_dropcanvas'
			}));
			this.dropcanvas.setStyle({
				zIndex: "100",
				position: "absolute",
				border: "solid 0px"
			});
			map.paper.jq.append(this.dropbox);
			map.paper.jq.append(this.dropcanvas);
		}
	},
	__put_dropbox:function(left,top){
		this.dropbox.setStyle({
			"left":left+'px',
			"top":top+'px',
			"width":80+"px",
			"height":20+"px",
			"opacity":0.6,
			"zIndex":103,
			"display":''
		});
	}
});