pie.mindmap.NodeTitleEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
    
    this._build_title_resizer();
    this._build_title_input_div();
	},

  _build_title_resizer:function(){
    var jq = jQuery('<div></div>')
      .css('position','absolute')
//      .css('top',1800)
//      .css('left',3500)
      .css('top',-777)
      .css('left',-777)
      .css('background-color','#ccc');

    this.title_resizer = {
      jq : jq
    }
  },

  _build_title_input_div:function(){
    var inputer_jq = jQuery("<textarea class='title-inputer'></textarea>")

    this.title_inputer = {
      jq : inputer_jq,
      el : $(inputer_jq[0])
    }

    var input_div_jq = jQuery("<div class='title-input-div'></div>")
      .append(inputer_jq)
      .hide();

    this.title_input_div = {
      jq : input_div_jq,
      el : $(input_div_jq[0])
    }

    //使之可选择
    Element.makeSelectable(this.title_inputer.el);

    //绑定回车 和 shift + 回车 事件
    Event.observe(this.title_inputer.el,"keydown",function(evt){
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
  },

  //被菜单调用的方法
	do_edit:function(node){
    this.node = node;

    this.map.paper.jq
      .append(this.title_resizer.jq)
      .append(this.title_input_div.jq);

    this._init_edit();

    this._position_input_div();
	},

  _position_input_div:function(){
    var node = this.node;

    var node_offset = node.jq.offset();
    var paper_offset = this.map.paper.jq.offset();

    var left = node_offset.left - paper_offset.left - 1; //计算有偏差要-1 我也不知道为什么
    var top = node_offset.top - paper_offset.top - 1; //计算有偏差要-1 我也不知道为什么

    this.title_input_div.jq
      .css('left',left).css('top',top).show();

    this.title_inputer.jq
      .select()
      .focus();

    node.jq.hide();
  },

  _init_edit:function(){
    var node = this.node;
    
    node.is_being_edit = true;
    node._oldtitle = node.title;

    this.title_resizer.jq
      .removeClass('root')
      .removeClass('node')
      .addClass(node.is_root() ? "root" : "node");

    this.title_inputer.jq
      .removeClass('iroot')
      .removeClass('inode')
      .addClass(node.is_root() ? "iroot" : "inode")
      .val(node.title);

    this._start_timer();
    this._rebind_change_title_handler();

    this._init_resizer();
  },


  //////////////
  _start_timer:function(){
    var node = this.node;

    if(!this.resizer_timer){
      this.resizer_timer = setInterval(function(){
        this.__update_resizer(node);
      }.bind(this),10);
    }
  },

	__update_resizer:function(node){
    var resizer_jq = this.title_resizer.jq;
    var html = resizer_jq.html();
    var new_html = node.simple_format(this.value());

    if(new_html != html){
      resizer_jq.html(new_html);
      this.__reset_inputer_size(resizer_jq.width(),resizer_jq.height());
    }
	},

	_init_resizer:function(){
    var node = this.node;

    this.title_resizer.jq.html(node.simple_format(this.value()));

    var width = node.jq.width();
    var height = node.jq.height();
    if(node.is_root()){
      width += 10;
      height += 10; //加上root在有边线时的双倍padding值，这个jquery不好取，硬编码
    }

    div_width = width + 2;  //div的宽度需要略宽一些，留出显示余地
    ipt_width = width + 100; //ipt的宽度需要略宽一些，否则会换行
    div_height = height;
    ipt_height = height;

    this.__set_dom_size(div_width, div_height, ipt_width, ipt_height);
	},

  //重新设置元素尺寸
  //TODO Refactor
	__reset_inputer_size:function(resizer_new_width, resizer_new_height){
		var div_width = this.title_input_div.jq.width();
		var div_height = this.title_input_div.jq.height();
		var ipt_width = this.title_inputer.jq.width();
		var ipt_height = this.title_inputer.jq.height();

    if(resizer_new_width > div_width - 2){ //多+出来的2，此时要-回去
      div_width = resizer_new_width + 2;
      ipt_width = resizer_new_width + 100;
    }
    if(resizer_new_height > div_height){
      div_height = resizer_new_height;
      ipt_height = resizer_new_height;
    }
    
		this.__set_dom_size(div_width, div_height, ipt_width, ipt_height);
	},

	__set_dom_size:function(diw_width, div_height, ipt_width, ipt_height){
    this.title_input_div.jq
      .css('width',diw_width).css('height',div_height);

    this.title_inputer.jq
      .css('width',ipt_width).css('height',ipt_height);
	},

  _rebind_change_title_handler:function(){
    var node = this.node;

    Event.stopObserving(this.title_inputer.el,"blur",this.cgt);
    pie.log('rebind');
    this.cgt = function(){
      this.__change_title(node);
    }.bind(this);
    
    Event.observe(this.title_inputer.el,"blur",this.cgt);
  },

	__change_title:function(node){
    if(node.is_being_edit){
      node.is_being_edit = false;

      //隐藏输入框
      this.title_input_div.jq.hide();

      //清除计时器
      if(this.resizer_timer) {
        clearInterval(this.resizer_timer);
        this.resizer_timer = null;
      }

      //保存数据，重排布
      node.set_title_and_save(this.value());

      //重新设置焦点
      this.title_inputer.blur();
      node.jq.focus();
    }
	},

  stop_edit:function(){
    this.title_inputer.el.blur();
  },
  value:function(){
    return this.title_inputer.jq.val();
  }
});