pie.mindmap.NodeTitleEditor = Class.create({
	initialize: function(options){
		this.log = function(){};
	},
	doEditTitle:function(node){
		var map = node.root.map;
		this.map = map;
		if(map.focus==node && map.editmode){
			node.isOnTitleEditStatus=true;
			node._oldtitle=node.title;
			
			this.log("edit:"+node.id);
			
			if(!map.resizer){
				map.resizer=Builder.node("div",{
					//style:"position:absolute;top:1700px; left:3400px;background-color:#ccc;"
					style:"position:absolute;top:-777px; left:-777px;background-color:#ccc;"
				});
			}
			
			if(!map.editorbox){
				map.title_textarea=Builder.node("textarea",{
					style:"overflow:hidden;"
				});
				map.editorbox=Builder.node("div",{
					"class":"editorbox"
				},map.title_textarea);
				
				Element.makeSelectable(map.title_textarea);
				
				Event.observe(map.title_textarea,"keydown",function(evt){
					var code=evt.keyCode;
					switch(code){
						case Event.KEY_RETURN:{
							if(evt.shiftKey){
							}else{
								//(map.__changeTitle.bind(map.focus))();
								map.title_textarea.blur();
								Event.stop(evt);
								return false;
							}
						}break;
					}
				}.bind(this));
			}
			
			if(!this.resizeTimer){
				this.resizeTimer = setInterval(function(){
					this.__update_resizer(node);
				}.bind(this),10);
			}
			
			var isRoot = (node == node.root);
			
			map.resizer.className = isRoot?"root":"node";
			map.title_textarea.className = isRoot?"title_textarea_root":"title_textarea";
			
			Event.stopObserving(map.title_textarea,"blur",this.cgt);
			this.cgt=function(){
				this.__changeTitle(node);	
			}.bind(this);
			Event.observe(map.title_textarea,"blur",this.cgt);
			
			//触发节点编辑事件后，根据title更新resizer内容
			//Element.update(map.resizer,node._get_formated_title());
			//根据title更新in-placed editor的value
			map.title_textarea.value=node.title;
			
			map.paper.el.appendChild(map.resizer);
			this.__init_resizer(node);
			map.paper.el.appendChild(map.editorbox);
			
			Position.clone(node.el,map.editorbox,{
				setWidth:false,setHeight:false
			});
			map.editorbox.show();
			map.title_textarea.select();
			map.title_textarea.focus();
			
			node.el.hide();
		}else{
			return false;
		}
	},
	__init_resizer:function(node){
		var map = this.map;
		Element.update(map.resizer, node.__format_title(map.title_textarea.value));
		this.__resetSize(node.width,node.height,true);
	},
	__update_resizer:function(node){
		var map = this.map;
		Element.update(map.resizer, node.__format_title(map.title_textarea.value));
		var nwidth = map.resizer.offsetWidth;
		var nheight = map.resizer.offsetHeight;
		this.__resetSize(nwidth,nheight);
	},
	__resetSize:function(nwidth,nheight,force){
		var map = this.map;
		var is_root = this.map.focus == this.map.focus.root;
		
		var width_editorbox = parseInt(map.editorbox.style.width);
		var height_editorbox = parseInt(map.editorbox.style.height);
		var width_textarea = parseInt(map.title_textarea.style.width);
		var height_textarea = parseInt(map.title_textarea.style.height);
		
		if(force){
			if (is_root) {
				width_editorbox = nwidth - 6; //可能需要调整
				width_textarea = nwidth - 12;
				height_editorbox = nheight - 6; //可能需要调整
				height_textarea = nheight - 10;
			} else {
				width_editorbox = nwidth - 6;
				width_textarea = nwidth - 10;
				height_editorbox = nheight - 1; //可能需要调整
				height_textarea = nheight - 5;
			}
		}else{
			if(nwidth>width_editorbox){
				if (is_root) {
					width_editorbox = nwidth - 6; //可能需要调整
					width_textarea = nwidth - 12;
				} else {
					width_editorbox = nwidth;
					width_textarea = nwidth - 4;
				}
			}
			if(nheight>height_editorbox){
				if (is_root) {
					height_editorbox = nheight - 6; //可能需要调整
					height_textarea = nheight - 10;
				} else {
					height_editorbox = nheight - 1; //可能需要调整
					height_textarea = nheight - 5;
				}
			}
		}
		this.___setSize(width_editorbox,height_editorbox,width_textarea,height_textarea);
	},
	___setSize:function(width_editorbox,height_editorbox,width_textarea,height_textarea){
		$(this.map.editorbox).setStyle({
			width:width_editorbox+"px",
			height:height_editorbox+"px"
		});
		$(this.map.title_textarea).setStyle({
			width:width_textarea+"px",
			height:height_textarea+"px"
		});
	},
	__changeTitle:function(node){
		var map=node.root.map;
		map.editorbox.hide();
		
		if(this.resizeTimer) {
			clearInterval(this.resizeTimer);
			this.resizeTimer = null;
		}
		
		//update node label
		Element.update(node.nodetitle.el,node.__format_title(map.title_textarea.value));
		//update node title
		if(pie.isIE()){
			//2009-1-19 IE下textarea.value赋值时，\n会自动被替换为\r\n，这里需要替换回来
			//否则每次提交都会导致新增一行
			node.title = map.title_textarea.value.replace(/\r\n/g,"\n");
        }else{
			node.title=map.title_textarea.value;
		}
		
		if(node.title==""){
			node.title=" ";
			node.nodetitle.el.update("&nbsp;");
		}
		node.el.show();
		
		//先去掉节点上的“被选择”样式，然后再计算宽高，才不会有错误		
		node.el.removeClassName('node_selected');
		node.el.removeClassName('root_selected');
		Object.extend(node,node.el.getDimensions());
		if(node.title!=node._oldtitle) {
			var record = map.opFactory.getTitleInstance(node);
			map._save(record);
			if(node.sub){
				node.sub.dirty=true;
			}
			map.reRank();
		}
		map.title_textarea.blur();
		node.el.focus();
		node.isOnTitleEditStatus=false;
		node.select();
	}
});

pie.mindmap.NodeFontEditor = Class.create({
	initialize: function(options){
    this.log = function(){};
    this.h = [];
    this.h[0] = "FF";
    this.h[1] = "CC";
    this.h[2] = "99";
    this.h[3] = "66";
    this.h[4] = "33";
    this.h[5] = "00";
	},
  doEditFont:function(node){

    this.get_cube();

    var fontsize = node.fontsize || 12;
    var fontcolor = node.fontcolor || '#000000';

    $('fontsize').value = fontsize;
    $('fontcolor').value = fontcolor;

    $("accept_font").observe("click",function(){
      var new_size = $('fontsize').value;
      var new_color = $('fontcolor').value;

      node.nodetitle.el.setStyle({
        'fontSize':new_size+'px',
        'color':new_color
      })
      node.fontsize = new_size;
      node.fontcolor = new_color;

      Lightview.hide();
    }.bind(this));

		Lightview.show({
		  href: '#fontselector',
		  title: '修改字体',
		  caption: '输入字体大小/颜色',
      width: '500px'
		});
  },
  get_cube: function(){// 创建颜色小方块
    if($('colorzone').innerHTML.blank()){

      for(var r=0; r<6; r++){
        var _ul = document.createElement("ul");
        for(var g=0; g<6; g++){
          for(var b=0; b<6; b++){
            var R = this.h[r];
            var G = this.h[g];
            var B = this.h[b];

            var _li = document.createElement("li");
            var _a = document.createElement("a");
            _a.style.background = "#"+ R + G + B;
            _li.title = "#"+ R + G + B;
            _li.appendChild(_a);
            _ul.appendChild(_li);
          };
        };
        $(_ul).observe("click", function(evt){
           var el = evt.element();
           var color = el.parentNode.title
           $('fontcolor').value = color;
        });
        $('colorzone').appendChild(_ul);
      };
    }
  }
});