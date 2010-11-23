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
var app_prefix = "app/mindmap_editor"

pie.mindmap = pie.mindmap || {};

pie.mindmap.BasicMapPaper = Class.create({
  initialize: function(paper,options){
    //options check
    options = options || {};

    Object.extend(this,options);

    this.paper = {
      id:paper,
      el:$(paper)
    };

    this.observer={
      el:$(this.paper.el.parentNode)
    };

    this.loader.mindmap=this;

    //logger
    this.log=function(str){};

    //params
    this.pausePeriod=500; //毫秒

    this.fw = 11;  //folder图片的宽度
    this.cr = 5;  //canvas层的偏移增量
    this.rr = 2;  //一级子节点的连接点半径
    this.mr = 3;  //子节点的margin值
    this.mr2 = this.mr * 2;

    this.lineColor=options.lineColor||"#5c5c5c";

    this.editmode=options.editmode||false;
    if(this.editmode){
      this._nodeTitleEditor = new pie.mindmap.NodeTitleEditor();
      this._nodeImageEditor = new pie.mindmap.NodeImageEditor();
      this._nodeNoteEditor = new pie.mindmap.NoteHandler();
      this._nodeFontEditor = new pie.mindmap.NodeFontEditor();
      this._noteEditor=new nicEditor({fullPanel : true}).panelInstance('mindmap-note-edit');
      if(pie.isIE() || pie.isChrome()){
        this._noteEditor.el=this._noteEditor.nicInstances[0].elm;
      }else{
        this._noteEditor.el=this._noteEditor.nicInstances[0].elm.firstChild.contentWindow;
      }
    }

    //Designated Canvas function
    this.connect = this._connectWithCanvas;

    //runtime
    this.root=null;
    this.el=null;
    this.focus=null;

    //operation record factory
    this.opFactory = new pie.mindmap.OperationRecordFactory({map:this});
    this.opQueue = [];
    this.ready_to_request = true;

    this.after_load=options.after_load;
    this.save_status_label=options.save_status_label;
  },
  load:function(){
    this.loader.load();
    return this;
  },
  _load:function(){
    //获取右键菜单
    this._createMenu();

    //生成HTML并缓存节点宽高
    var start = new Date();
    this.paper.el.update(this._getEl());
    this.root._cacheDimensions();
    var end = new Date();
    this.log("生成HTML.."+(end-start)+"ms");

    //初始化，计算坐标
    start = new Date();
    //获取paper的宽高，并折半
    var dim=this.paper.el.getDimensions();
    this.paper.xoff=dim.width/2;
    this.paper.yoff=dim.height/2;
    //获取observer的宽高
    Object.extend(this.observer,this.observer.el.getDimensions());
    //定位编辑区
    this.observer.el.scrollLeft=this.paper.xoff;
    this.observer.el.scrollTop=this.paper.yoff;
    //定位根结点
    this.root.posX=(this.observer.width-this.root.width)/2+this.paper.xoff;
    this.root.posY=(this.observer.height-this.root.height)/2+this.paper.yoff;
    this.root.container.el.style.left=this.root.posX+"px";
    this.root.container.el.style.top=this.root.posY+"px";
    //this.log("observer width:"+this.observer.width+" height:"+this.observer.height);
    //this.log("root width:"+this.root.width+" height:"+this.root.height);
    //this.log("root position:"+this.root.posX+","+this.root.posY);
    end = new Date();
    this.log("初始化.."+(end-start)+"ms");

    this.reRank();
    //this.reBind();
    new pie.drag.Page(this.paper.el,{beforeDrag:function(){
      this.nodeMenu.unload();
      if(this.focus && this.focus.isOnTitleEditStatus){
        this.title_textarea.blur();
      }
    }.bind(this)});
    this.after_load();
  },
  _getEl:function(){
    if(this.el==null){
      this.el=this.root._getContainerEl();
      this._bindGlobalCommonEvents();
      if (this.editmode) {
        this._bindGlobalEditEvents();
      }else{
        this._bindGlobalShowEvents();
      }
      this._bindHotkeyDispatcher();
    }
    return this.el;
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
    this.log("排列.." + (end - start) + "ms");

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
    var fw = this.fw;//折叠点的宽度
    var padding = 10;//节点的纵向间距

    var children_h = 0;
    var children_w = 0;
    if (node.fold != 1) {
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

    if (children_h == 0) {
          h = label_h;
          node.top = 0;
          content.top = 0;
    }else if (label_h > children_h) {
      var fcc = node.children.first();
      var lc = node.children.last().container;
      var lcc = node.children.last();
      var h1 = fcc.top + fcc.height;
      var h2 = lc.top + lcc.top + lcc.height;
      top = label_h - (h1 + h2) / 2;
      content.top = top;
      node.top = 0;
      h = top + children_h;
    }else if (label_h < children_h) {
      var fcc = node.children.first();
      var lc = node.children.last().container;
      var lcc = node.children.last();
      var h1 = fcc.top + fcc.height;
      var h2 = lc.top + lcc.top + lcc.height;
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
    if(node.sub.putright){
      content.left = label_w + fw;
      folder.left = label_w;

      content.el.style.left = content.left + "px";
      folder.el.style.left = folder.left + "px";

      content.el.style.right = "";
      folder.el.style.right = "";
      node.el.style.right = "";
      container.el.style.right = "";
    }else{
      content.right = label_w + fw;
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

    folder.top = label_h - fw / 2 + node.top;
    container.height = h;
    container.width = label_w + fw + node.content.width;

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
      if(sub.putright){
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
        if(sub.putright){
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
  connect:{},
  _connectWithDiv: function(){
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
  node.canvas.height = node.container.height+this.cr;

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
    branch.setAttribute("height", node.branch.height+this.cr*2);
    branch.setStyle({
      left:node.branch.left+"px",
      top:node.branch.top-this.cr*2+"px"
    });
  },
  __countBranch:function(node){
    if(node.sub.putright){
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

    node.branch.top += this.cr;
  },
  _drawOnCanvas:function(sub){
    sub.canvas.el=$(sub.canvas.id);
    var ctx = sub.canvas.el.getContext('2d');
    ctx.strokeStyle=this.lineColor;
    //ctx.clearRect(0, 0, sub.canvas.width, sub.canvas.height);
    this._connectWithCanvas_recursion(sub,ctx);
  },
  _drawOnBranch:function(sub){
    if(sub.free) return;
    sub.branch.el=$(sub.branch.id);
    var ctx = sub.branch.el.getContext('2d');
    ctx.fillStyle=this.lineColor;
    ctx.strokeStyle=this.lineColor;
    //ctx.clearRect(0, 0, sub.branch.width, sub.branch.height);
    this._connectRootWithCanvas(sub,ctx);
  },
  _connectWithCanvas_recursion: function(node,ctx){
    var container = node.container.el;
    var pos = this.__getNodePosition(node);
    ctx.beginPath();
    ctx.moveTo(pos.left, pos.bottom);
    ctx.lineTo(pos.right, pos.bottom);
    ctx.stroke();
    if (node.fold != 1) {
      node.children.each(function(child){
        this._connectWithCanvas_recursion(child, ctx);
        ctx.beginPath();
        ctx.moveTo(pos.right, pos.bottom);
        ctx.bezierCurveTo(pos.right, pos.bottom, pos.right, child.canvas.bottom, child.canvas.left, child.canvas.bottom);
        ctx.stroke();
      }.bind(this));
    }
  },
  _connectRootWithCanvas:function(node,ctx){
    var line_weight = 2;
    if(node.sub.putright){
      if (node.branch.type == 0) {
        ctx.beginPath();
        ctx.moveTo(0,node.branch.height+this.cr - line_weight);
        ctx.lineTo(node.branch.width-this.rr, this.cr);
        ctx.lineTo(line_weight,node.branch.height+this.cr);
        ctx.stroke();
        ctx.fill();
        ctx.beginPath();
        ctx.arc(node.branch.width-this.rr, 0+this.cr,this.rr,0,Math.PI * 2,true);
        ctx.fill();
      }else{
        ctx.beginPath();
        ctx.moveTo(0,this.cr+line_weight);
        ctx.lineTo(node.branch.width-this.rr, node.branch.height+this.cr);
        ctx.lineTo(line_weight,this.cr);
        ctx.stroke();
        ctx.fill();
        ctx.beginPath();
        ctx.beginPath();
        ctx.arc(node.branch.width-this.rr, node.branch.height+this.cr,this.rr,0,Math.PI * 2,true);
        ctx.fill();
      }
    }else{
      if (node.branch.type == 0) {
        ctx.beginPath();
        ctx.moveTo(node.branch.width,node.branch.height+this.cr - line_weight);
        ctx.lineTo(0+this.rr, this.cr);
        ctx.lineTo(node.branch.width-line_weight,node.branch.height+this.cr);
        ctx.stroke();
        ctx.fill();
        ctx.beginPath();
        ctx.arc(0+this.rr, 0+this.cr,this.rr,0,Math.PI * 2,true);
        ctx.fill();
      }else{
        ctx.beginPath();
        ctx.moveTo(node.branch.width,this.cr+line_weight);
        ctx.lineTo(0+this.rr, node.branch.height+this.cr);
        ctx.lineTo(node.branch.width-line_weight,this.cr);
        ctx.stroke();
        ctx.fill();
        ctx.beginPath();
        ctx.beginPath();
        ctx.arc(0+this.rr, node.branch.height+this.cr,this.rr,0,Math.PI * 2,true);
        ctx.fill();
      }
    }
  },
  __getNodePosition: function(node){
    var top = node.top.round();
      var bottom = top + node.height;
      if(node.sub.putright){
      var left = node.left;
      var right = left + node.width + this.fw/2;
    }else{
      var left = node.right;
      var right = left + node.width + this.fw/2;
    }
    if(node.sub!=node){
      var pct=node.parent.content;
      var voff=node.container.top+node.parent.canvas.top-(node.parent.top-pct.top).round();
      top+=voff;
      bottom+=voff;
      if(node.sub.putright){
        var hoff=pct.left+node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }else{
        var hoff=pct.right+node.container.width-node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }
    };

    if(!node.sub.putright){
      left=node.container.width-left;
      right=node.container.width-right;
    }

    node.canvas.top = top;
    node.canvas.bottom = bottom;
    node.canvas.left = left;
    node.canvas.right = right;

    return {
      "top": top,
      "right": right,
      "bottom": bottom,
      "left": left
    };
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
    
    if(!node.sub.putright) left = left - node.width;
    
    //this.__setTempBox(left,top,width,height);
    posreg.set(node.id, [node, left, top, left+width, top+height]);
    
    if(1!=node.fold){
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
			left:l+'px',
			top:t+'px',
			width:w+"px",
			height:h+"px",
			opacity:0.3,
			zIndex:103
		});
		this.root.map.paper.el.appendChild(this.posbox);
	},

  _createMenu:function(){
    try{
      this.nodeMenu=new pie.mindmap.Menu({observer:this.paper.el,afterload:function(){
        this.__scrollto(this.nodeMenu);
      }.bind(this)});
      this.nodeMenu.addItem("新增　　 [Ins]",{handler:function(){
        this.focus.createNewChild();
      }.bind(this)});
      this.nodeMenu.addItem("删除　　 [Del]",{handler:function(){
        this.focus.remove();
      }.bind(this),flag:function(){
        return this.focus!=this.root;
          }.bind(this)});
      this.nodeMenu.addItem("编辑标题 [空格]",{handler:function(){
        this._nodeTitleEditor.doEditTitle(this.focus);
      }.bind(this)})
      this.nodeMenu.addItem("节点图片 [I]",{handler:function(){
        this._nodeImageEditor.doEditImage(this.focus);
      }.bind(this)});
      this.nodeMenu.addItem("移除图片",{handler:function(){
        this._nodeImageEditor.doRemoveImage(this.focus);
      }.bind(this),flag:function(){
        return this.focus.image.url;
      }.bind(this)});
      this.nodeMenu.addItem("编辑备注",{handler:function(){
        this._noteEditor.el.focus()
      }.bind(this)});
      //2010.10.20
      this.nodeMenu.addItem("节点字体",{handler:function(){
        this._nodeFontEditor.doEditFont(this.focus);
      }.bind(this)});
    }catch(e){alert(e)}
  },
  _bindGlobalCommonEvents:function(){
    //全局公用事件
  },
  _bindGlobalShowEvents:function(){
    //浏览状态特定事件
    this.paper.el.observe("mousedown",function(){
      Tips.hideAll();
    })
  },
  _bindGlobalEditEvents:function(){
    //编辑状态特定事件
  },
  _bindHotkeyDispatcher:function(){
    //绑定快捷键
    document.stopObserving("keydown",window._hotkeyDispatcher);
    window._hotkeyDispatcher=this.hotkeyDispatcher.bind(this);
    document.observe("keydown",window._hotkeyDispatcher);
  },
  hotkeyDispatcher:function(evt){
    if(!this.focus || this.focus.isOnTitleEditStatus){
      return false;
    }
    var evtel=Event.element(evt);
    var tagName=evtel.tagName;
    if(pie.isIE()){
      this.log(tagName);
      if(tagName != "DIV" || false){//evtel==this.noteEditor.el) {
        return false;
      }
    }else{
      if (tagName != "HTML" && tagName != "BODY") {
        return false;
      }
    }
    var code=evt.keyCode;
    if(!this.isOnNoteEditStatus){
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
            this._nodeTitleEditor.doEditTitle(this.focus);
          }break;
          case 73:{
            this._nodeImageEditor.doEditImage(this.focus);
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
        if(sub.putright){
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
        if(sub.putright){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  _left:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      if(focus.sub.putright){
        //节点右排布
        focus.parent.select();
        this.log("left:"+focus.id);
      }else{
        //节点左排布
        if (1 != focus.fold) {
          if (focus.children.first()) {
            focus.children[((0+focus.children.length-1)/2).floor()].select();
            this.log("left:" + focus.id);
          }
        }
      }
    }else{
      //根节点
      focus.children.each(function(sub){
        if(!sub.putright){
          sub.select();
          throw $break;
        }
      }.bind(this))
    }
  },
  _right:function(){
    var focus=this.focus;
    if(focus!=focus.root){
      if(focus.sub.putright){
        //节点右排布
        if (1 != focus.fold) {
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
        if(sub.putright){
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
      return false;
    }
    Object.extend(this.observer,this.observer.el.getDimensions());
    var left,top,toleft,totop;

    var oel=this.observer.el;

    var off1=oel.cumulativeOffset();
    var off2=node.el.cumulativeOffset();

    left=oel.scrollLeft;
    top=oel.scrollTop;

    //scrollbar width
    var sw=22;

    var leftoff=off2[0]-left-off1[0];
    var topoff=off2[1]-top-off1[1];

    if(leftoff<0){
      toleft=off2[0]-off1[0];
      new Effect.Tween(oel, left, toleft,{duration:0.4},"scrollLeft");
    }else{
      leftoff+=node.width-this.observer.width+sw;
      if(leftoff>0){
        toleft=off2[0]-off1[0]-this.observer.width+node.width+sw;
        new Effect.Tween(oel, left, toleft,{duration:0.4},"scrollLeft");
      }
    }

    if(topoff<0){
      totop=off2[1]-off1[1];
      new Effect.Tween(oel, top, totop,{duration:0.4},"scrollTop");
    }else{
      topoff+=node.height-this.observer.height+sw;
      if(topoff>0){
        totop=off2[1]-off1[1]-this.observer.height+node.height+sw;
        new Effect.Tween(oel, top, totop,{duration:0.4},"scrollTop");
      }
    }
  },
  _pause:function(pausePeriod){
    if(this.pause==true){
      return true;
    }else{
      this.pause=true;
      pausePeriod=pausePeriod||this.pausePeriod;
      setTimeout(function(){this.pause=false}.bind(this),pausePeriod);
      return false;
    }
  },
  /**
   * 2009-1-8 jerry
   * 改为细粒度保存之后，可能（但不确定）会出现客户端请求提交顺序和服务端请求处理顺序不同的问题
   * 从而导致导图编辑中可能会出现难以预期的问题，导致数据的损坏
   * 为了避免这一问题，修改为当导图不处于等待提交的状态时，所有record并不提交，而是放入队列
   * 当等待提交状态改变时，提交整个队列。同时服务器端按照顺序处理操作指令请求
   *
   * 操作顺序
   * 如果当前不是编辑模式，方法直接退出
   * 如果当前是DEMO，直接退出
   * 如果当前编辑器不在READY状态，先把操作记录放入队列，然后退出
   * 
   */
  _save:function(record){
    if(!this.editmode) return;
    if(this.id == 'demo') return;

    if(record!=null) this.opQueue.push(record);
    if(!this.ready_to_request) return;

    var pars = 'operations=' + encodeURIComponent(this.opQueue.toJSON());
    new Ajax.Request("/"+app_prefix+"/mindmaps/do",{
      parameters:pars,
      method:"PUT",
      onCreate:function(){
        this.ready_to_request=false;
        this.__change_save_status_label('status_notice','保存中...','show')

        this.opQueue = [];
      }.bind(this),
      onSuccess:function(trans){
        if(trans.status != 200){
          this.__on_save_error()
        }else{
          this.log(trans.responseText);
          this.ready_to_request=true;
          this.__change_save_status_label('status_success','保存完毕','hide');
          if(this.opQueue.length > 0) this._save();
        }
      }.bind(this),
      onFailure:function(trans){
        this.__on_save_error()
      }.bind(this)
    });
  },
  __on_save_error:function(){
    //第一步 闪烁提示
    this.__change_save_status_label('status_error','保存失败','Pulsate');
    //第二步 白板遮盖
    this.lock_whiteboard = $(Builder.node('div',{style:'position:absolute;background-color:#93A9D5;z-index:900;'}));
    this.lock_whiteboard.setStyle({opacity:0.5});
    this.lock_whiteboard.clonePosition(this.paper.el,{setLeft:false,setTop:false});
    $(this.paper.el).insert({before:this.lock_whiteboard});
    //第三步 提示刷新
    this.lock_tips_window = $(Builder.node('div',{id:'lock_tips_window',style:'position:absolute;background-color:white;border:solid 1px;z-index:901;font-size:14px;'},[
      Builder.node('div',{style:'background-color:red;color:white;text-align:center;font-size:12px;'},'导图保存失败'),
      Builder.node('p',{style:'padding:0 0 0 30px;'},"由于网络原因，导致导图自动保存失败，不能继续编辑"),
      Builder.node('p',{style:'padding:0 0 0 30px;'},["> ",Builder.node('a',{href:'javascript:window.location.reload()'},'点击这里刷新编辑器')])
    ]));
    var left =$('mindmap').getWidth()/2 - 200;
    var top =$('mindmap').getHeight()/2 - 50;
    this.lock_tips_window.setStyle({
      'width':'400px',
      'height':'100px',
      'padding':'2px',
      'left':left+'px',
      'top':top+'px'
    });
    $('mindmap').insert({before:this.lock_tips_window});
  },
  __change_save_status_label:function(classname,text,mode){
    if(this.save_status_label){
      this.save_status_label.className=classname;
      this.save_status_label.update(text);
      switch(mode){
        case 'show':{
          this.save_status_label.show();
        }break;
        case 'hide':{
          setTimeout(function(){
            this.save_status_label.hide();
          }.bind(this),1000);
        }break;
        case 'Pulsate':{
          new Effect.Pulsate(this.save_status_label,{pulses:100,duration:60});
        }
      }
    };
  }
});

pie.mindmap.Node = Class.create({
  initialize: function(options,parent){
    this.log=function(){};
    //options check
    options = options || {};

    Object.extend(this,options);

    if(this.maxid!=null){
      this.root=this;
      this.map=parent;
    }else{
      this.parent=parent;
      this.root=parent.root;
      if(this.parent==this.root){
        this.sub=this;
      }else{
        this.sub=this.parent.sub;
      }
    }

    this.canvas = {};
    this.branch = {};

    this.putright=(this.putright!="0"?true:false);

    //递归地生成子节点对象
    var _children=[];
    this.children.each(function(cld,index){
      var cldnode=new pie.mindmap.Node(cld,this);
      if(index>0){
        cldnode.prev=_children[index-1];
        _children[index-1].next=cldnode;
      }
      cldnode.index=index;
      cldnode.left=0;
      cldnode.top=0;
      _children.push(cldnode);
    }.bind(this));
    this.children=_children;

    this.dirty=true;
  },
  _getContainerEl:function(){
    try{
      if (this.el == null) {
        this.nodeimg={};
        if (this.image.url) { //这个判断方式不靠谱，需要修改JSON
          this.image.el = $(Builder.node("img",{
            'src':this.image.url,
            'height':this.image.height,
            'width':this.image.width
          }))
          this.nodeimg = {
            el: $(Builder.node("div", {
              "class": "nodeimg"
            },this.image.el))
          }
        }

        this.noteicon={};
        if(this.note!=""&&this.note!='<br>'){
          this.noteicon={
            el:$(Builder.node("div",{
              "class":"noteicon"
            }))
          }
        }

        this.nodetitle={
          el:$(Builder.node("div",{
            "class":"nodetitle"
          }))
        }
        this.nodetitle.el.update(this._get_formated_title());

        this.nodebody={
          el:$(Builder.node("div",{
            "class":"nodebody"
          },[this.nodetitle.el,this.noteicon.el||[]]))
        };

        this.el = $(Builder.node("div", {
          id:this.id,
          "class": (this.root==this ? "root" : "node"),
          "style":"position:absolute"
        },[this.nodeimg.el||[],this.nodebody.el]));

        if(!this.fold) this.fold=0
        this.folder={
          id:"f_"+this.id,
          el:$(Builder.node("div", {
            "class": this.fold==0 ? "foldhandler_minus" : "foldhandler_plus",
            "style":"position:absolute;"+(this.children.length==0?"display:none;":"")
          }))
        };

        this.content={
          id:"children_"+this.id,
          top:0,
          el:$(Builder.node("div", {
            "class": "mindmap-children",
            "style":"position:absolute"
          }))
        };

        this.children.each(function(child){
          this.content.el.insert(child._getContainerEl());
        }.bind(this));

        this.container={
          id:"c_"+this.id,
          top:0,
          el:$(Builder.node("div", {
            "class": "mindmap-container",
            "style":"position:absolute"
          }, this.maxid!=null ? [this.el, this.content.el] : [this.el, this.folder.el, this.content.el]))
        };

        this._bindCommonEvents();
        if (this.root.map.editmode) {
          this._bindEditEvents();
        }else{
          this._bindShowEvents();
        }

      }
    }catch(e){
      alert(e)
    }
    return this.container.el;
  },
  _get_formated_title:function(){
    //对节点标题格式进行预处理（换行）
    //此处的机制需要调整，以后考虑
    if( /\n|\s|\\/.test(this.title) ){
      return this.__format_title(this.title);
    }
    return this.title.escapeHTML();
  },
  __format_title:function(titlestr){
    return titlestr.escapeHTML().replace(/\n/g, "<br/>").replace(/\s/g, "&nbsp;").replace(/>$/, ">&nbsp;");
  },
  _cacheDimensions:function(){
    if(this.width==null){
      Object.extend(this,this.el.getDimensions());
      this.children.each(function(cld){
        cld._cacheDimensions();
      }.bind(this));
    }
  },
  _bindCommonEvents:function(){
    //令节点不可选择
    this.el.makeUnselectable();

    //绑定鼠标滑过事件，可以将事件上提，改成mousemove事件以优化——jerry
    this.el.observe("mouseover",function(){
      this.el.addClassName(this==this.root ? 'root_over':'node_over');
    }.bind(this))
    .observe("mouseout",function(){
      this.el.removeClassName('root_over').removeClassName('node_over');
    }.bind(this));

    //绑定折叠点相关事件，同样可以上提以优化
    var fel=this.folder.el;
    fel.observe("mouseover",function(){
      fel.addClassName('foldhandler_over');
    }.bind(this))
    .observe("mouseout",function(){
      fel.removeClassName('foldhandler_over').removeClassName('foldhandler_down');
    }.bind(this))
    .observe("mouseup",function(){
      fel.removeClassName('foldhandler_down');
    }.bind(this))
    .observe("mousedown",function(evt){
      evt.stop();
      if(this.root.map.pause){return false;}
      fel.addClassName('foldhandler_down');
    }.bindAsEventListener(this))
    .observe("click",this.toggle.bind(this));

    //绑定节点单击选定事件
    this.el.observe("click",function(evt){
      if(this.root.map.editmode && Event.isLeftClick(evt)){
        this.root.map._nodeTitleEditor.doEditTitle(this);
      }
      this.select();
    }.bind(this))
    .observe("contextmenu",function(){
      this.select();
    }.bind(this));

    if(pie.isIE() && this.root.map.editmode){
      this.el.observe("dblclick",function(evt){
        this.root.map._nodeTitleEditor.doEditTitle(this);
      }.bind(this));
    }

    if(this.root.map.editmode){
      //note编辑器
      //safari在这里的事件绑定有问题，待修改
      try{
        Element.observe($(this.root.map._noteEditor.el),"focus",function(){
          this.root.map._nodeNoteEditor.onNoteEditBegin(this)
        }.bind(this));
      }catch(e){}
      if (this != this.root) {
        new pie.drag.PinNode(this);
      }
    }
  },
  _bindShowEvents:function(){
    if(this.note!=""){
      new Tip(this.el, this.note,{
        title:this.title,
        width:400,
        border:2,
        borderColor:"#C7C7C7",
        radius:2,
        delay:0,
        stem:'topLeft',
        closeButton: true,
        hideOn: { element: 'closeButton', event: 'click'},
        hideOthers: true
      });
    }
  },
  _bindEditEvents:function(){
    //右键菜单
    this.root.map.nodeMenu.bind(this.el,"bottom",this);
  },
  toggle:function(evt){
    var map=this.root.map;
    if(map._pause()){return false;}
    this._toggle();
    var record = map.opFactory.getToggleInstance(this);
    map._save(record);
    this.sub.dirty=true;
    map.reRank();
    //map.__scrollto(this);
  },
  _toggle:function(){
    if(1==this.fold){
      this._expand();
    }else{
      this._collapse();
    }
    this.content.el.toggle();
  },
  _expand:function(){
    this.folder.el.className="foldhandler_minus";
    this.fold=0;
  },
  _collapse:function(){
    //当focus在子孙节点中时，选中当前节点
    var p=this.root.map.focus;
    if(p)
    while(p!=this.root){
      if(p.parent==this){
        this.select();
        break;
      }
      p=p.parent;
    }
    this.folder.el.className="foldhandler_plus";
    this.fold=1;
  },
  select:function(keep){
    var map=this.root.map;
    if(this.isOnTitleEditStatus) return false;
    if(map.focus){
      if(map.focus.isOnTitleEditStatus){
        map.title_textarea.blur();
      }
      map.focus.el.removeClassName('node_selected');
      map.focus.el.removeClassName('root_selected');
      //如果切换节点时正处于note编辑状态，则终止note编辑，并提交
      if(map.focus!=this && map.isOnNoteEditStatus){
        map._nodeNoteEditor.onNoteEditEnd();
      }
    }
    map.focus=this;
    if (this.root == this) {
      this.el.addClassName('root_selected');
    } else {
      this.el.addClassName('node_selected');
    }
    if(!keep) map.__scrollto(this);
    map.nodeMenu.unload();

    if(map.editmode) {
      if(this.note==''||this.note=='<br>'){
        if(pie.isIE()){
          map._noteEditor.nicInstances[0].setContent('');
        }else{
          //Firefox
          map._noteEditor.nicInstances[0].setContent('<br>');
        }
      }else{
        map._noteEditor.nicInstances[0].setContent(this.note);
      }
    }

    return this;
  },
  getPrevCousin:function(){
    var p=this;
    var i=0;
    do{
      var pp=p;
        while(pp=pp.prev){
        if(pp.sub.putright==p.sub.putright){
          break;
        }
      }
      if (pp) {
        while(i>0){
          i--;
          if((pp.children.length>0)&&pp.fold!=1){
            pp=pp.children.last();
          }
        }
        return pp;
      }
      i++;
    }while(p=p.parent);
    return this;
  },
  getNextCousin:function(){
    var p=this;
    var i=0;
    do{
      var pp=p;
      while(pp=pp.next){
        if(pp.sub.putright==p.sub.putright){
          break;
        }
      }
      if(pp){
        while(i>0){
          i--;
          if((pp.children.length>0)&&pp.fold!=1){
            pp=pp.children.first();
          }
        }
        return pp;
      }
      i++;
    }while(p=p.parent);
    return this;
  },
  createNewSibling:function(){
    var map = this.root.map;
    if(map._pause()){
      return false;
    }
    if (this == this.root) {
      return false;
    } else {
      var child = this.parent._newChild(this.index);
      var record = map.opFactory.getInsertInstance(child);
      map._save(record);
      map.reRank();
      child.select();
      new Effect.Pulsate(child.el,{duration:0.4});
    }
  },
  createNewChild:function(){
    var map = this.root.map;
    if(map._pause()){
      return;
    }
    var child = this._newChild();
    this._expand();
    var record = map.opFactory.getInsertInstance(child);
    map._save(record);
    map.reRank();
    child.select();
    new Effect.Pulsate(child.el,{duration:0.4});
  },
  _newChild:function(index){
    var isRoot=(this==this.root);
    var child={
      "image":{"width": null, "border": null, "url": null, "height": null},
      "fold": "0",
      "note": "",
      "children":[],
      "title": "NewSubNode",
      "putright": "1",
      "id": this.root.maxid++
    };

    if(isRoot){
      if(this.map.focus.parent == this){
        child.putright = this.map.focus.putright;
      }
    }

    var cldnode=new pie.mindmap.Node(child,this);
    cldnode.left=0;
    cldnode.top=0;

    var container = cldnode._getContainerEl();
    if (index!=null) {
      var part1 = this.children.slice(0, index+1);
      var part2 = this.children.slice(index+1);
      cldnode.prev = part1.last();
      cldnode.prev.next = cldnode;
      cldnode.next = part2.first();
      if(cldnode.next) cldnode.next.prev = cldnode;
      part1.push(cldnode);
      this.children = part1.concat(part2);
      var targetel=isRoot ? cldnode.prev.canvas.el : cldnode.prev.container.el;
      targetel.insert({after: container});
    } else {
      cldnode.prev = this.children.last();
      this.children.push(cldnode);
      var targetel=this.content.el;
      targetel.insert({bottom: container});
    }
    cldnode._cacheDimensions();
    this.children.each(function(chd,idx){
      chd.index=idx;
    }.bind(this));
    if(!isRoot) this.folder.el.show();
    cldnode.sub.dirty=true;
    return cldnode;
  },
  remove:function(){
    if(this.root.map._pause() || this == this.root){
      return false;
    }
    var parent=this.parent;
    this.container.el.remove();

    parent.children=parent.children.without(this);
    //set to default
    parent.__tidyChildren();

    if (parent.children.length == 0) {
      if (parent == this.root) {
      //to do..
      } else {
        parent.content.el.hide();
        parent.folder.el.hide();
        parent.select();
      }
    } else {
      if (this.next) {
        this.next.select();
      } else {
        this.prev.select();
      }
    }
    if (parent == this.root) {
      this.canvas.el.remove();
      if(!this.free) this.branch.el.remove();
    }
    var record = this.root.map.opFactory.getDeleteInstance(this);
    this.root.map._save(record);
    this.sub.dirty=true;
    this.root.map.reRank();
  },

  __tidyChildren:function(){
    this.children.each(function(child,index){
      child.index=index;
      if (index > 0) {
        child.prev = this.children[index - 1];
      }else{
        child.prev = null;
      }
      if (index < this.children.length - 1) {
        child.next = this.children[index + 1];
      }else{
        child.next = null;
      }
      child.container.top = 0;
    }.bind(this));
  },
  
  //改变对应的一级子节点
  __changesub:function(sub){
    this.sub.dirty = true;

    this.sub = sub;
    this.children.each(function(cld){
      cld.__changesub(sub);
    }.bind(this));
    
    this.sub.dirty = true;
  },
  //节点高亮
  hilight:function(colorstr){
    this.nodebody.el.setStyle({backgroundColor:colorstr})
  }
});

/*JSONLoader*/
pie.mindmap.JSONLoader = Class.create({
  initialize: function(options){
    options = options || {};

    this.url = options.url;

    //运行时参数
    this.json = {};
  },
  request:function(callback){
    new Ajax.Request(this.url+".js",{
      method:"get",
      onSuccess:callback.bind(this)
    })
  },
  load:function(){
    //show loading animate...
    
    //加载
    this.request(function(trans){
      var json=trans.responseText.evalJSON();
      //json以嵌套形式返回，将来需要改成数组形式
      this.mindmap.root = new pie.mindmap.Node(json,this.mindmap);
      this.mindmap._load();
    }.bind(this));
  }
});
