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

    var pars =
      'map=' + this.id + '&' +
      'md5=' + this.md5 + '&' +
      'operations=' + encodeURIComponent(this.opQueue.toJSON());
    new Ajax.Request("/mindmaps/do",{
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
          var new_md5 = trans.responseText.evalJSON().md5;
          this.md5 = new_md5;
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

pie.mindmap.BasicMapPaper.addMethods(pie.mindmap_canvas_draw_module);