pie.mindmap.NodeTitleEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
	},
	do_edit:function(node){
		var map = this.map;

    node.is_being_edit = true;
    node._oldtitle = node.title;

    this._build_title_resizer();
    this._build_title_input_div();
    this._set_resizer_timer(node);

    this._set_dom_classname(node);

    this._rebind_change_title_handler(node);

    this.title_inputer.value = node.title;

    map.paper.el.appendChild(this.title_resizer);
    this._init_resizer(node);
    map.paper.el.appendChild(this.title_input_div);

    Position.clone(node.el,this.title_input_div,{
      setWidth:false,setHeight:false
    });
    this.title_input_div.show();
    this.title_inputer.select();
    this.title_inputer.focus();

    node.el.hide();
	},
  
  _build_title_resizer:function(){
    if(!this.title_resizer){
      this.title_resizer = Builder.node("div",{
        //style:"position:absolute; top:1700px; left:3400px; background-color:#ccc;"
        style:"position:absolute; top:-777px; left:-777px; background-color:#ccc;"
      });
    }
  },

  _build_title_input_div:function(){
    if(!this.title_input_div){
      
      this.title_inputer = $(Builder.node("textarea",{
        style:"overflow:hidden;"
      }));
      
      this.title_input_div = $(Builder.node("div",{
        "class":"title_input_div"
      },this.title_inputer));

      //使之可选择
      Element.makeSelectable(this.title_inputer);

      //绑定回车 和 shift + 回车 事件
      Event.observe(this.title_inputer,"keydown",function(evt){
        var code = evt.keyCode;
        switch(code){
          case Event.KEY_RETURN:{
            if(evt.shiftKey){
              //do nothing
            }else{
              this.stop_edit();
              Event.stop(evt);
              return;
            }
          }break;
        }
      }.bind(this));
      
    }
  },

  _set_resizer_timer:function(node){
    if(!this.resizer_timer){
      this.resizer_timer = setInterval(function(){
        this.__update_resizer(node);
      }.bind(this),10);
    }
  },

  _set_dom_classname:function(node){
    this.title_resizer.className = node.is_root() ? "root" : "node";
    this.title_inputer.className = node.is_root() ? "title_inputer_root" : "title_inputer";
  },

  _rebind_change_title_handler:function(node){
    Event.stopObserving(this.title_inputer,"blur",this.cgt);
    this.cgt = function(){
      this.__change_title(node);
    }.bind(this);
    Event.observe(this.title_inputer,"blur",this.cgt);
  },

	_init_resizer:function(node){
		Element.update(this.title_resizer, node.simple_format(this.value()));
		this.__reset_size(node.width, node.height, true);
	},
  
	__update_resizer:function(node){
		Element.update(this.title_resizer, node.simple_format(this.value()));
		var nwidth = this.title_resizer.offsetWidth;
		var nheight = this.title_resizer.offsetHeight;
		this.__reset_size(nwidth,nheight);
	},

  //重新设置元素尺寸
  //TODO Refactor
	__reset_size:function(nwidth, nheight, force){
		var is_root = this.map.focus == this.map.focus.root;

		var w_v = parseInt(this.title_input_div.style.width);
		var h_v = parseInt(this.title_input_div.style.height);
		var w_i = parseInt(this.title_inputer.style.width);
		var h_i = parseInt(this.title_inputer.style.height);

		if(force){
			if (is_root) {
				w_v = nwidth - 6; //可能需要调整
				w_i = nwidth - 12;
				h_v = nheight - 6; //可能需要调整
				h_i = nheight - 10;
			} else {
				w_v = nwidth - 6;
				w_i = nwidth - 10;
				h_v = nheight - 1; //可能需要调整
				h_i = nheight - 5;
			}
		}else{
			if(nwidth>w_v){
				if (is_root) {
					w_v = nwidth - 6; //可能需要调整
					w_i = nwidth - 12;
				} else {
					w_v = nwidth;
					w_i = nwidth - 4;
				}
			}
			if(nheight>h_v){
				if (is_root) {
					h_v = nheight - 6; //可能需要调整
					h_i = nheight - 10;
				} else {
					h_v = nheight - 1; //可能需要调整
					h_i = nheight - 5;
				}
			}
		}
		this.__set_dom_size(w_v,h_v,w_i,h_i);
	},

	__set_dom_size:function(w_v, h_v, w_i, h_i){
		$(this.title_input_div).setStyle({
			width  : w_v + "px",
			height : h_v + "px"
		});
		$(this.title_inputer).setStyle({
			width  : w_i + "px",
			height : h_i + "px"
		});
	},
  
	__change_title:function(node){
    if(node.is_being_edit){
      node.is_being_edit = false;
      
      //隐藏输入框
      this.title_input_div.hide();

      //清除计时器
      if(this.resizer_timer) {
        clearInterval(this.resizer_timer);
        this.resizer_timer = null;
      }

      //保存数据，重排布
      node.set_title_and_save(this.value());

      //重新设置焦点
      this.title_inputer.blur();
      node.el.focus();
    }
	},


  stop_edit:function(){
    this.title_inputer.blur();
  },

  value:function(){
    return this.title_inputer.value;
  }
});