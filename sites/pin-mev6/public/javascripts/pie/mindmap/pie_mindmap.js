/** pineditor version 0.5.5.1214
 *  (c) 2006-2008 MindPin.com - songliang
 
 *  require:
 *  prototype.js
 *  builder.js
 *  effects.js
 *  pie_core.js
 *  pie_dragdrop.js
 *  pie_menu.js
 *  pie_opfactory.js
 *  excanvas.js (for MSIE6+)
 *
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/
pie.mindmap = pie.mindmap || {};

pie.mindmap.BasicMapPaper = Class.create({
  initialize: function(paper_id,options){
    //options check
    options = options || {};
    Object.extend(this,options);
    this.editmode = (options.editmode == true);

    this._init_paper(paper_id);
    this._init_scroller();

    this._init_const();

    this.nodes = new Hash();

    //初始化右键菜单
    this._createMenu();
  },

  _init_paper:function(paper_id){
    this.paper = {
      jq : jQuery(paper_id)
    };
  },
  _init_scroller:function(){
    this.scroller = {
      jq : this.paper.jq.parent()
    }
  },
  _init_const:function(){
    //logger
    this.log = pie.log;

    //params
    this.pause_period = 500; //毫秒

    this.foldhandler_width  = 11;  //folder图片的宽高值
    this.canvas_overflow    = 6;  //canvas层的边缘溢出量

    this.lineColor = "#5c5c5c";

    if(this.editmode){
      this._node_title_editor = new pie.mindmap.NodeTitleEditor(this);
      this._node_image_editor = new pie.mindmap.NodeImageEditor(this);
      this._node_note_editor  = new pie.mindmap.NodeNoteEditor(this);
      this._node_color_editor  = new pie.mindmap.NodeColorEditor(this);
    }

    //Designated Canvas function
    this.connect = this._connectWithCanvas;

    //operation record factory
    this.opFactory  = new pie.mindmap.OperationRecordFactory({map:this});
    this.mr_factory = new pie.mindmap.ModifyingResponseFactory({map:this});
  },



  load:function(){
    jQuery.ajax({
      url : this.data_url,
      type : 'GET',
      dataType : 'json',
      success : function(data){
        this.root = new pie.mindmap.Node(data,this);
        this.initial_data();
      }.bind(this),
      error : function(){
        jQuery.facebox('思维导图数据异常，载入失败。');
      }
    })
    return this;
  },
  initial_data:function(){
    var paper    = this.paper;
    var root     = this.root;

    //生成HTML并缓存节点宽高
    var paper_jq = paper.jq;

    this.el = root.container.el;
    paper_jq.html(this.el);
    root.cache_dimensions();


    //初始化，计算坐标
    //获取paper的宽高，并折半
    paper.xoff = paper_jq.width() / 2;
    paper.yoff = paper_jq.height() / 2;
    
    //定位编辑区
    this.recenter();

    //定位根结点
    this._set_root_position();

    this.reRank();

    new pie.drag.Page(paper.jq[0],{beforeDrag:function(){
      this.nodeMenu.unload();
      this.stop_edit_focus_title();
    }.bind(this)});
  
    this._bindHotkeyDispatcher();
    
    this.root.select();
  },
  
  recenter:function(){
    try{
      var scroller_jq = this.scroller.jq;
      scroller_jq.scrollLeft(this.paper.xoff - scroller_jq.width()/2);
      scroller_jq.scrollTop(this.paper.yoff - scroller_jq.height()/2);
    }catch(e){
      alert(e)
    }
  },

  _set_root_position:function(){
    var paper = this.paper;
    var root  = this.root;

    root.posX = (0 - root.width)/2 + paper.xoff;
    root.posY = (0 - root.height)/2 + paper.yoff;

    jQuery(root.container.el)
      .css('left',root.posX)
      .css('top',root.posY);
    root.container.el.style.top = root.posY+"px";
  },

  __prepare_canvas_for_ie:function(){
    //prepare for IE 6+
    if(typeof G_vmlCanvasManager != 'undefined') G_vmlCanvasManager.init_(document);
  },
  reRank:function(){
    //1.重新计算并排布坐标
    var start = new Date();
    this.root.children.each(function(sub){
      if(sub.dirty){
        this.setCoord(sub);
      }
    }.bind(this));

    this.setRootCoord(this.root);
    var end = new Date();
    pie.log("排列.." + (end - start) + "ms");

    //2.为每个sub节点准备canvas画布
    start = new Date();
    this.root.children.each(function(sub){
      if(sub.dirty){
        this.connect(sub);
      }
      this._connectWithCanvas_branch(sub);
    }.bind(this));

    this.__prepare_canvas_for_ie();
    this.root.el.style.zIndex="101";

    //3.画线
    this.root.children.each(function(sub){
      if(sub.dirty){
        this._drawOnCanvas(sub);
        sub.dirty=false;
      }
      this._drawOnBranch(sub);
    }.bind(this));

    end = new Date();
    this.log("画线.." + (end - start) + "ms");

    this.posRegister=this._updatePosRegister(this.root);
    //Element.update("posreg",this.posRegister);
  },
  //精确到像素的节点排列递归函数
  setCoord: function(node){
    var foldhandler_width = this.foldhandler_width;//折叠点的宽度
    var padding = 10;//节点的纵向间距

    var children_h = 0;
    var children_w = 0;
    if (!node.closed) {
      node.children.each(function(child){
        var cld = child.el;
        children_h += this.setCoord(child);
        var w = child.container.width;
        if (w > children_w)
          children_w = w;
      }.bind(this));
    }else{
      Element.hide(node.content.el);
    }

    var label_w = node.width, label_h = node.height;

    var container = node.container;
    var content = node.content;
    var folder = node.folder;
    var h = 0, top = 0;

    var fcc,lc,lcc,h1,h2;

    if (children_h == 0) {
      h = label_h;
      node.top = 0;
      content.top = 0;
    }else if (label_h > children_h) {
      fcc = node.children.first();
      lc = node.children.last().container;
      lcc = node.children.last();
      h1 = fcc.top + fcc.height;
      h2 = lc.top + lcc.top + lcc.height;
      top = label_h - (h1 + h2) / 2;
      content.top = top;
      node.top = 0;
      h = top + children_h;
    }else if (label_h < children_h) {
      fcc = node.children.first();
      lc = node.children.last().container;
      lcc = node.children.last();
      h1 = fcc.top + fcc.height;
      h2 = lc.top + lcc.top + lcc.height;
      top = (h1 + h2) / 2 - label_h;
      content.top = 0;
      node.top = top>0?top:0;
      h = children_h;
    }else {
      h = children_h;
      node.top = 0;
      content.top = 0;
    }

    content.height = children_h;
    content.width = children_w;

    //左右排列
    if(node.sub.put_on_right()){
      content.left = label_w + foldhandler_width;
      folder.left = label_w;

      content.el.style.left = content.left + "px";
      folder.el.style.left = folder.left + "px";

      content.el.style.right = "";
      folder.el.style.right = "";
      node.el.style.right = "";
      container.el.style.right = "";
    }else{
      content.right = label_w + foldhandler_width;
      folder.right = label_w;
      node.right = 0;
      container.right = 0;

      content.el.style.right = content.right + "px";
      folder.el.style.right = folder.right + "px";
      node.el.style.right = node.right + "px";
      container.el.style.right = container.right + "px";

      content.el.style.left = "";
      folder.el.style.left = "";
    }

    folder.top = label_h - foldhandler_width / 2 + node.top;
    container.height = h;
    container.width = label_w + foldhandler_width + node.content.width;

    var p= node.prev;

    if (p) {
      if(!p.container) this.log(p.title+"****")
      if(node.parent!=this.root){
        container.top = p.container.top + p.container.height + padding;
        h += padding;
      }else{
        if(node.free){
          container.el.style.left=node.freeX + 'px';
          container.top = p.container.top + p.container.height - node.top + padding;
          container.el.style.top=node.freeY - node.top + 'px';
        }
      }
    }

    container.el.style.height = container.height + "px";
    container.el.style.width = container.width + "px";
    if(node.free!=true) container.el.style.top = container.top + "px";

    content.el.style.height = content.height + "px";
    content.el.style.width = content.width + "px";
    content.el.style.top = content.top + "px";

    folder.el.style.top = folder.top + "px";

    node.el.style.top = node.top + "px";
    return h;
  },
  //根节点和一级子节点坐标排布函数
  setRootCoord:function(root){
    Element.makeUnselectable(root.el);
    var padding = 10;
    root.top = root.el.offsetTop;
    root.left = root.el.offsetLeft;
    var leftOff = root.left + (root.width + 50);
    var rightFall = -padding, leftFall = -padding;

    //step 1 horizon
    root.children.each(function(sub){
      if(sub.free) return;
      var c=sub.container;
      if(sub.put_on_right()){
        c.left = leftOff;
        rightFall += c.height + padding;
      }else{
        c.left = root.left * 2 + root.width - leftOff - c.width;
        leftFall += c.height + padding;
      }
      c.el.style.left = c.left + "px";
    }.bind(this));
    //step 2 vertical
    var rh=root.height;
    var rt=root.top;
    var rightTop=rt-(rightFall-rh)/2;
    var leftTop=rt-(leftFall-rh)/2;
    root.children.each(function(sub){
      var c=sub.container;
      if(sub.free){
      }else{
        if(sub.put_on_right()){
          c.top = rightTop;
          rightTop += c.height+padding;
        }else{
          c.top = leftTop;
          leftTop += c.height+padding;
        }
        c.el.style.top = c.top + "px";
      }
      var canvas=sub.canvas;

      if (canvas.el) {
            canvas.el.clonePosition(c.el, {
                setWidth: false,
                setHeight: false
            });
      }
    }.bind(this));
  },
  _connectWithCanvas: function(node){
      //connect nodes with Canvas
  var canvas=node.canvas.el;
  if (!canvas) {
    Element.setStyle(node.container.el,{
            zIndex: "101"
        });

        node.canvas.id = "canvas_" + node.id;

    canvas = Builder.node("canvas", {
      id: node.canvas.id
    });

    $(canvas).setStyle({
      zIndex: "100",
      position: "absolute",
      border: "solid 0px"
    });

    Element.insert(node.container.el,{after: canvas});

        canvas.clonePosition(node.container.el, {
            setWidth: false,
            setHeight: false
        });
  }

  node.canvas.width = node.container.width;
  node.canvas.height = node.container.height+this.canvas_overflow;

      canvas.setAttribute("width", node.canvas.width);
      canvas.setAttribute("height", node.canvas.height);
  },
  _connectWithCanvas_branch:function(node){
    if(node.free){
      if(node.branch.el){
        Element.remove(node.branch.el);
        node.branch={};
      }
      return;
    }

    //计算branch坐标
    this.__countBranch(node);
    var branch=node.branch.el;
    if (!branch) {
      node.branch.id = "branch_" + node.id;
      branch = Builder.node("canvas", {
        id: node.branch.id
      });
      $(branch).setStyle({
        zIndex: "100",
        position: "absolute",
        border: "solid 0px"
      });

      node.container.el.insert({after: branch});
    }
    branch.setAttribute("width", node.branch.width);
    branch.setAttribute("height", node.branch.height+this.canvas_overflow*2);
    branch.setStyle({
      left:node.branch.left+"px",
      top:node.branch.top-this.canvas_overflow*2+"px"
    });
  },
  
  __countBranch:function(node){
    if(node.sub.put_on_right()){
      node.branch.left = node.root.left + node.root.width / 2;
      node.branch.width = node.container.left-node.branch.left;
    }else{
      node.branch.left = node.container.left + node.container.width;
      node.branch.width = node.root.left + node.root.width / 2 - node.branch.left;
    }

    if (node.container.top + node.top + node.height < node.root.top + node.root.height / 2) {
      node.branch.top = (node.container.top + node.top + node.height).round();
      node.branch.height = node.root.top + node.root.height/2 - node.branch.top;
      node.branch.type = 0;
    } else {
      node.branch.top = node.root.top + node.root.height / 2;
      node.branch.height = (node.container.top + node.top + node.height - node.branch.top).round();
      node.branch.type = 1;
    }

    node.branch.top += this.canvas_overflow;
  },

  //更新坐标缓存
  _updatePosRegister:function(root){
    //debug..
    $A(document.getElementsByName('postemp')).each(Element.remove);
    var posreg=new Hash();
    var left=root.left + this.root.posX;
    var top=root.top + this.root.posY;
    var width=root.width;
    var height=root.height;
    posreg.set(root.id,[root,left,top,left+width,top+height]);
    //this.__setTempBox(left,top,width,height);
    root.children.each(function(cld){
      this._updatePosRegister_recursion(cld,posreg);
    }.bind(this))
    return posreg;
  },
  _updatePosRegister_recursion:function(node,posreg){
    var left,top,width,height;
    top = node.canvas.top + node.sub.container.top - node.top + this.root.posY;
    width = node.width;
    height = node.container.height;
    left = node.canvas.left + node.sub.container.left + this.root.posX;
    
    if(!node.sub.put_on_right()) left = left - node.width;
    
    //this.__setTempBox(left,top,width,height);
    posreg.set(node.id, [node, left, top, left+width, top+height]);
    
    if(!node.closed){
      node.children.each(function(child){
        this._updatePosRegister_recursion(child,posreg);
      }.bind(this))
    }
  },

  /*测试用的方法，生成覆盖层*/
	__setTempBox:function(l,t,w,h){
		this.posbox=Builder.node('div',{
			name:'postemp',
			'style':"position:absolute; background-color:#E8641B;border-top:solid 5px #DF0024;border-bottom:solid 5px #DF0024;"
		});
		Element.setStyle(this.posbox,{
			left    : l+'px',
			top     : t+'px',
			width   : w+"px",
			height  : h+"px",
			opacity : 0.3,
			zIndex  : 103
		});
		this.paper.jq.append(this.posbox);
	},
  _bindHotkeyDispatcher:function(){
    //绑定快捷键
    document.stopObserving("keydown",window._hotkeyDispatcher);
    window._hotkeyDispatcher=this.hotkeyDispatcher.bind(this);
    document.observe("keydown",window._hotkeyDispatcher);
  },
  hotkeyDispatcher:function(evt){
    if(!this.focus || this.focus.is_being_edit){
      return;
    }
    var evtel=Event.element(evt);
    var tagName=evtel.tagName;
    if(pie.isIE()){
      this.log(tagName);
      if(tagName != "DIV" || false){//evtel==this.noteEditor.el) {
        return;
      }
    }else{
      if (tagName != "HTML" && tagName != "BODY") {
        return;
      }
    }
    var code=evt.keyCode;
    if(!this.is_on_note_edit_status){
      Event.stop(evt);
      //当编辑器处于NOTE编辑状态时，所有节点操作的快捷键都被禁止
      switch(code){
        case Event.KEY_UP:{
          this._up();
        }break;
        case Event.KEY_DOWN:{
          this._down();
        }break;
        case Event.KEY_LEFT:{
          this._left();
        }break;
        case Event.KEY_RIGHT:{
          this._right();
        }break;
      }

      if(this.editmode){
        //编辑专用快捷键
        switch(code){
          case Event.KEY_RETURN:{
            this.focus.createNewSibling();
          }break;
          case 45:{
            this.focus.createNewChild();
          }break;
          case 46:{
            this.focus.remove();
          }break;
          case 32:{
            this.edit_focus_title();
          }break;
          case 73:{
            this.edit_focus_image();
          }break;
        }
      }
    }
  },
  _up:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      focus.getPrevCousin().select();
      this.log("up:"+focus.id);
    }else{
      focus.children.each(function(sub){
        if(sub.put_on_right()){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  _down:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      focus.getNextCousin().select();
      this.log("down:"+focus.id);
    }else{
      focus.children.reverse(false).each(function(sub){
        if(sub.put_on_right()){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  _left:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      if(focus.sub.put_on_right()){
        //节点右排布
        focus.parent.select();
        this.log("left:"+focus.id);
      }else{
        //节点左排布
        if (!focus.closed) {
          if (focus.children.first()) {
            focus.children[((0+focus.children.length-1)/2).floor()].select();
            this.log("left:" + focus.id);
          }
        }
      }
    }else{
      //根节点
      focus.children.each(function(sub){
        if(!sub.put_on_right()){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  _right:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      if(focus.sub.put_on_right()){
        //节点右排布
        if (!focus.closed) {
          if (focus.children.first()) {
            focus.children[((0+focus.children.length-1)/2).floor()].select();
            this.log("left:" + focus.id);
          }
        }
      }else{
        //节点左排布
        focus.parent.select();
        this.log("left:"+focus.id);
      }
    }else{
      //根节点
      focus.children.each(function(sub){
        if(sub.put_on_right()){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  /**
   * 选择节点如果节点不在观察窗内时平滑滚动的函数
   */
  __scrollto:function(node){

    if(!node.el.visible()){
      return;
    }

    var scrollbar_width = 20;

    var scroller_jq     = this.scroller.jq
    var scroller_width  = scroller_jq.width();
    var scroller_height = scroller_jq.height();
    var scroller_offset = scroller_jq.offset();
    
    var node_offset = jQuery(node.el).offset();



    var xdiff = 0;
    //左边出界了
    if(node_offset.left < scroller_offset.left){
      xdiff = (node_offset.left - scroller_offset.left);
    }else{
      //右边出界了
      var node_right = node_offset.left + node.width;
      var scroller_right = scroller_offset.left + scroller_width - scrollbar_width;
      if(node_right > scroller_right){
        xdiff = node_right - scroller_right;
      }
    }

    var ydiff = 0;
    //上边出界了
    if(node_offset.top < scroller_offset.top){
      ydiff = (node_offset.top - scroller_offset.top);
    }else{
      //右边出界了
      var node_bottom = node_offset.top + node.height;
      var scroller_bottom = scroller_offset.top + scroller_height - scrollbar_width;
      if(node_bottom > scroller_bottom){
        ydiff = node_bottom - scroller_bottom;
      }
    }

    if((xdiff!=0)||(ydiff!=0)){
      scroller_jq.animate({
        'scrollLeft':'+='+xdiff,
        'scrollTop':'+='+ydiff
      },400);
    }
  },

  _pause:function(pause_period){
    if(this.pause == true){
      return true;
    }else{
      this.pause = true;
      pause_period = pause_period || this.pause_period;
      setTimeout(function(){this.pause = false}.bind(this), pause_period);
      return false;
    }
  }
});

pie.mindmap_focus_methods = {
  edit_focus_image:function(){
    if(this._can_edit_focus()){
      this._node_image_editor.do_edit_image(this.focus);
    }
  },
  edit_focus_note:function(){
    if(this._can_edit_focus()){
      this._node_note_editor.do_edit_note(this.focus);
    }
  },
  edit_focus_color:function(){
    if(this._can_edit_focus()){
      this._node_color_editor.do_edit_font(this.focus);
    }
  },
  edit_focus_title:function(){
    if(this._can_edit_focus()){
      this._node_title_editor.do_edit(this.focus);
    }
  },
  stop_edit_focus_title:function(){
    if(this.focus && this.focus.is_being_edit){
      this._node_title_editor.stop_edit();
    }
  },
  _can_edit_focus:function(){
    return this.editmode && this.focus;
  }
}

pie.mindmap.BasicMapPaper
  .addMethods(pie.mindmap_canvas_draw_module)
  .addMethods(pie.mindmap_menu_module)
  .addMethods(pie.mindmap_save_module)
  .addMethods(pie.mindmap_cooprate_response_module)
  .addMethods(pie.mindmap_focus_methods);