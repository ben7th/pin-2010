/** pielib Tree version 0.3
 *  (c) 2006-2008 MindPin.com - songliang
 *  
 *  require:
 *  scriptaculous 1.8.1 with prototype.js ver 1.6.0.1
 *  
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

pie.tree={};

/**
 * Tree Node
 */
pie.tree.Node = Class.create();
pie.tree.Node.prototype = {
  initialize: function(id,options){
    //options check
    options = options || {};
    Object.extend(this,options);

    //日志
    this.log = function(){};//new pie.Logger().get("debugger");

    //节点id
    this.id = id;
    //当前节点的父节点id
    this.parent_id = options.parent_id==null?"root":options.parent_id;
    //节点显示名称
    this.name = options.name;

    this.expanded=options.expanded==null?false:options.expanded;
        
    this.sicon='/javascripts/pie/tree/s.gif';

    //节点关闭时图标
    this.icon_c = options.icon_c;
    //节点打开时图标
    this.icon_o = options.icon_o;

    //以下为运行时参数
    this.parent=null;  //父节点对象
    this.children=[];  //子节点数组
    this.islast=true;  //是否父节点的最后一个节点
    this.tree=null;    //节点所在的tree
    this.root=null;    //节点的根节点

    this.leaf=options.leaf==null?true:options.leaf;

    this.hasChild=function(){
      return !this.leaf;
    };

    this._getTitle=function(){
      if(this.tree.getExtraTitle){
        return this.tree.getExtraTitle.bind(this)();
      }else{
        return this.name;
      }
    };

    this.childloaded=false;  //子节点dom是否已加载

    this.indents=[];  //间隔值数组

    this.el=null;    //节点dom元素对象
    this.container=null;  //节点包含对象dom
    this.indentel;  //间隔dom元素
    this.iel=[];  //间隔dom数组
    this.fel;    //折叠点dom
    this.iconel=null;    //图标dom
    this.label=null;  //节点名称标签dom对象
    this.content=null;    //子节点容器dom
    this.cels=[];      //子节点dom数组
  },
  isleaf:function(){
    return !this.hasChild();
  },
  prevnode:function(){
    if(this==this.root) return this;
    var index=this.parent.children.indexOf(this)-1;
    return index>=0?this.parent.children[index]:this.parent;
  },
  //加载节点
  _getEl:function(){
    if (this.el == null) {

      if (this != this.root) {
        //一般节点
        this.indentel=this._getIndentEl();
        this.fel=this._getFolderEl();
        var showContainer=true;
      }else{
        //根结点
        if (this.tree.showRootFolder) {
          this.indents = [0];
          this.fel = this._getFolderEl();
        }else{
          this.fel = this._getFolderEl();
          this.fel.hide();
        }
        var showContainer=this.tree.showRoot;
      }

      if(this.tree.useIcon){
        //创建节点图标
        //这部分需要移入构造函数
        if(!this.icon_c){
          this.icon_c=this.hasChild()?"pie-tree-folder":"pie-tree-leaf";
        }
        if(!this.icon_o){
          this.icon_o=this.hasChild()?"pie-tree-folder-open":"pie-tree-leaf";
        }
        this.iconel=Builder.node("img",{
          "class":this.expanded ? this.icon_o : this.icon_c,
          src:this.sicon
        });
      }

      this.label=Builder.node("span",{"class":"pie-tree-label"},this._getTitle());

      this.content=this._getContentEl();

      var container=Builder.node("div",{"class":"pie-tree-container"},[this.indentel,this.fel,this.iconel,this.label])

      this.container=showContainer?container:$(container).hide();

      this.el=Builder.node("div",{id:"p-t-n-"+this.id,"class":"pie-tree-node"},[this.container,this.content]);

      Element.makeUnselectable(this.el);
    }
    return this.el;
  },
  _getContentEl:function(){
    var content;

    if(this.hasChild()){
      this.cels=[];
      if (this.expanded) {
        this.children.each(function(child){
          this.cels.push(child._getEl());
        }.bind(this));
        this.childloaded=true;
      }

      content=Builder.node("div",{
        id:"pie-tree-n-"+this.id+"-content",
        "class":"pie-tree-content",
        style:'display:' + ((this.root == this || this.expanded) ? 'block' : 'none') + ';'
      },this.cels);

    }else{
      content=Builder.node("div",{
        id:"pie-tree-n-"+this.id+"-content",
        "class":"pie-tree-content",
        style:'display:none;'
      });
    }

    return content;
  },
  //获取缩进和控制点元素，使用在递归之中
  _getIndentEl:function(){
    var iel=[];
    this.indents=this.parent.indents.clone();
    if(this.parent!=this.root) this.indents.push(this.parent.islast?0:1);
    this.indents.each(function(indent){
      var imgel=Builder.node("img",{
        "class":(indent == 1 && this.tree.useLine) ? "pie-tree-elbow-line" : "pie-tree-empty",
        src:this.sicon
      });
      iel.push(imgel);
    }.bind(this));

    var indent=Builder.node("span",{"class":"pie-tree-indent"},iel);

    this.iel=iel;

    return indent;
  },
  _getFolderEl:function(){
    var fel=[];
    if(this.hasChild()){
      //有子节点
      var classname;
            if (this.tree.useLine){ 
          classname = this.expanded?(this.islast?"pie-tree-elbow-end-minus":"pie-tree-elbow-minus"):(this.islast?"pie-tree-elbow-end-plus":"pie-tree-elbow-plus");
      }else{
        classname = this.expanded?"pie-tree-elbow-minus-nl":"pie-tree-elbow-plus-nl";
      }
      fel=Builder.node("img",{
        "class":classname,
        src:this.sicon
      });
      Event.observe(fel,"click",function(evt){
        //切换节点折叠状态
        evt.stop();
        this.toggle();
      }.bindAsEventListener(this));
    }else{
      //无子节点
      fel=Builder.node("img",{
        "class":this.tree.useLine?(this.islast?"pie-tree-elbow-end":"pie-tree-elbow"):"pie-tree-empty",
        src:this.sicon
      })
    }
    return fel;
  },

  //重新生成dom，用于插入了节点以后
  updateBuild:function(){
    this.log("updateBuild "+this.id+" : "+this.name);

    this.content.insert(this.children.last()._getEl());
    //1 插入节点
    //2 找到上一个节点
    var len=this.children.length;
    if(len==1){
      if(this!=this.root&&this.parent.expanded){
        //在子节点上插入新子节点
        //更改图标
        this.icon_c="pie-tree-folder";
        this.icon_o="pie-tree-folder-open";
        $(this.iconel).removeClassName("pie-tree-leaf").addClassName(this.icon_o);
        //则给此节点绑定点击方法
        Event.observe(this.fel,"click",function(evt){
          //切换节点折叠状态
          evt.stop();
          this.toggle();
        }.bindAsEventListener(this));
      }
    }else{
      //在原来的父节点上添加新节点
      old_last_node=this.children[len-2];
      this.tree._re=old_last_node.indents.length;
      old_last_node._updateBuild_recursion();
      //更改邻居节点图标
      if(this.tree.useLine){
        if(old_last_node.hasChild()){
          if(old_last_node.expanded){
            $(old_last_node.fel).removeClassName("pie-tree-elbow-end-minus").addClassName("pie-tree-elbow-minus")
          }else{
            $(old_last_node.fel).removeClassName("pie-tree-elbow-end-plus").addClassName("pie-tree-elbow-plus")
          }
        }else{
          $(old_last_node.fel).removeClassName("pie-tree-elbow-end").addClassName("pie-tree-elbow");
        }
      }
    }
  },

  _updateBuild_recursion:function(){
    //遍历某节点已展开的子孙节点的indents
    //令indents[0]=1
    //并相应地修改className
    this.children.each(function(child){
      child.indents[this.tree._re]=1;
      child._updateBuild_recursion();
    }.bind(this));

    if(this.childloaded&&this.tree.useLine){
      this.children.each(function(child){
        var iel = child.iel[this.tree._re];
        $(iel).removeClassName("pie-tree-empty").addClassName("pie-tree-elbow-line");
      }.bind(this));
    }
  },

  //选择节点
  select:function(){
    if(this.tree.focus){
      this.tree.focus.container.removeClassName('selected');
    }
    this.tree.focus=this;
    this.container.addClassName('selected');
    this.tree.afterSelected();
    return true;
  },

  //节点展开折叠状态切换
  toggle:function(){
    if(this.expanded){
      this.collapse();
    }else{
      this.expand();
    }
  },
  __collapse_show:function(){
    if(this.tree.animate){
      var el=this.children.first().el;
      var mtop=Element.getHeight(this.content);
      var d=mtop/620;
      new Effect.Tween(el.style, 0, -mtop,{duration:d,afterFinishInternal:function(){
        el.style.marginTop=0+"px";
        this.content.hide();
      }.bind(this)},function(value){
        this.marginTop=value+"px";
      });
    }else{
      this.content.hide();
    }
  },
  __expand_show:function(){
    if(this.tree.animate){
      var el=this.children.first().el;
      var mtop=Element.getHeight(this.content);
      el.style.marginTop=-mtop+"px";
      this.content.show()
      var d=mtop/620;
      new Effect.Tween(el.style, -mtop, 0,{duration:d},function(value){
        this.marginTop=value+"px";
      });
    }else{
      this.content.show();
    }
  },

  _loadChildEls:function(){
    this.cels=[];
    //如果没有子节点，则不加载
    this.log("_loadChildEls: node.children:"+this.children);
    if(this.hasChild()){
      this.children.each(function(child){
        var nel=child._getEl();
        this.cels.push(nel);
        $(this.content).insert(nel);
      }.bind(this));
      this.childloaded=true;
    }
  },

  //展开至某节点
  _expandTo:function(){
    if(this==this.root) return false;
    var nd=this.parent;
    var path=[];
    do{
      if(!nd.expanded) path.push(nd);
      nd=nd.parent;
    }while(nd)

    path.reverse().each(function(nd){
      nd._expand();
    });

    return this;
  },

  //展开一个节点（私有）
  _expand:function(callback){
    var iconel=$(this.iconel);
    iconel.removeClassName(this.icon_c).addClassName(this.icon_o);
    var fel=$(this.fel);
    var content=$(this.content);
    fel.className=this.tree.useLine?(this.islast?"pie-tree-elbow-end-minus":"pie-tree-elbow-minus"):("pie-tree-elbow-minus-nl");

    var start=new Date().getTime();
    //加载content
    this.log("_expand:"+this.name+", childloaded:"+this.childloaded);
    if (!this.childloaded) {
      if(this.tree.loader){
        //远程加载节点
        this.tree.loader.load(this,callback);
      }else{
        this._loadChildEls();
        this.__expand_show();
        this.expanded=true;
      }
    }else{
      this.__expand_show();
      this.expanded=true;
    }

    var end=new Date().getTime();

    this.log(this.id+" open .. "+(end-start)+"ms");
  },

  //展开至节点
  expand:function(callback){
    if(!this.expanded&&this.hasChild()){
      this._expandTo();
      this._expand(callback);
    }
  },

  //折叠节点
  collapse:function(){
    if(this.expanded){
      var iconel=$(this.iconel);
      iconel.removeClassName(this.icon_c).addClassName(this.icon_o);
      var fel=$(this.fel);
      var content=$(this.content);
      fel.className=this.tree.useLine?(this.islast?"pie-tree-elbow-end-plus":"pie-tree-elbow-plus"):("pie-tree-elbow-plus-nl");
      this.__collapse_show();
      this.expanded=false;
    }
  },

  remove:function(){
    $(this.el).remove();
    this.log(this.islast);
    //调整其他节点的样式
    if(this.islast){
      var parent=this.parent;
      var len=parent.children.length;
      parent.children=parent.children.without(this);
      if(len>1&&this.tree.useLine){
        var prev=parent.children[len-2];
        $(prev.fel).removeClassName("pie-tree-elbow").addClassName("pie-tree-elbow-end");
        prev.islast=true;
      }else{
        this.log("remove last child");
        parent.leaf=true;
        parent.childloaded=false;
        parent.expanded=false;
        //修改节点图标
        if (parent != this.root) {
          $(parent.iconel).removeClassName(parent.icon_o).addClassName("pie-tree-leaf");
          parent.icon_o = "pie-tree-leaf";
          parent.icon_c = "pie-tree-leaf";
        }
        //修改连接处图标
        if (this.tree.useLine) {
          this.log("修改连接处图标"+parent.islast);
          $(parent.fel)
          .removeClassName("pie-tree-elbow-end-minus")
          .removeClassName("pie-tree-elbow-minus")
          .addClassName(parent.islast?"pie-tree-elbow-end":"pie-tree-elbow");
        }else{
          $(parent.fel)
          .removeClassName("pie-tree-elbow-minus-nl")
          .addClassName("pie-tree-empty");
        }
      }
    }
  },

  rename:function(newname){
    this.name=newname;
    Element.update(this.label,this._getTitle());
  }
}

/**
 * Tree Panel
 */
pie.tree.TreePanel = Class.create();
pie.tree.TreePanel.prototype = {
  initialize:function(panel,options){
    options=options||{};

    //日志
    this.log = function(){};//new pie.Logger().get("debugger");

    //特征参数
    this.inOrder=options.inOrder==null?true:options.inOrder;
    this.useLine=options.useLine==null?true:options.useLine;
    this.useIcon=options.useIcon==null?true:options.useIcon;

    this.animate=options.animate=null?false:options.animate;

    this.showRoot=options.showRoot==null?true:options.showRoot;
    this.showRootFolder=options.showRootFolder==null?true:options.showRootFolder;

    this.afterSelected=options.afterSelected||function(){};

    //panel
    this.panel=$(panel);

    //loader
    this.loader=null||options.loader;
    if(this.loader) this.loader.tree=this;

    this.getExtraTitle=options.getExtraTitle;

    //根节点
    this.root=new pie.tree.Node("root",{
      name:"这是根节点",
      icon_c:"pie-tree-root",
      icon_o:"pie-tree-root"
    });
    this.root.root=this.root;
    this.root.tree=this;

    //节点数组 -> HASH
    this.nodes=new Hash();
    this.nodes.set(this.root.id,this.root);

    this.freenodes=new Hash();  //没有父节点的节点Hash

    //以下为运行时参数
    this.el=null;
    this.loaded=false;

    this.covered=this.panel;

    this.focus=null;//焦点


  },

  setRootNode:function(id,options){
    this.nodes.unset("root");
    var root=new pie.tree.Node("root",{
      name:"这是根节点",
      icon_c:"pie-tree-root",
      icon_o:"pie-tree-root"
    });
    Object.extend(root,options);
    this.root=root;
    this.root.root=root;
    this.root.tree=this;
    this.nodes.set(this.root.id,this.root);
  },

  //根据id获取节点
  getNode:function(id){
    return this.nodes.get(id);
  },

  //增加节点
  addNode:function(nodeid,nodeoptions){

    if(this.getNode(nodeid)) {return false;}  //不能添加重复id的节点

    var node=new pie.tree.Node(nodeid,nodeoptions);

    //关联新加入的节点的父节点
    node.parent=this.getNode(node.parent_id);

    if(node.parent){
      plast=node.parent.children.last();
      if(plast) plast.islast=false;
      node.parent.children.push(node);
      node.parent.leaf=false;
    }else{
      if (!this.inOrder) {
        var pArray = this.freenodes.get(node.parent_id)||[];
        pArray.push(node);
        this.freenodes.set(node.parent_id, pArray);
      }
    }

    //关联新加入的节点的子节点，
    //当this.inOrder=true时，表示节点加入是按照层级顺序的，则忽略这一步以节约时间
    if(!this.inOrder){
      var pArray = this.freenodes.get(node.id)||[];
      pArray.each(function(child){
        nlast=node.children.last();
        if(nlast) nlast.islast=false;
        node.children.push(child);
        child.parent=node;
        node.leaf=false;
      }.bind(this));
      this.freenodes.set(node.id, []);
    }

    node.tree=this;
    node.root=this.root;
    this.nodes.set(node.id,node);

    return node;
  },

  load:function(){
    if(this.loader){
      //this.log("load root from json loader");
      this.loader.loadRoot();
    }else{
      this._load();
      this.root.expand();
    }
  },
  //树的加载函数
  _load:function(){
    if (!this.loaded) {
      var start=new Date().getTime();
      this.panel.insert(this._getEl());
      this.panel.style.overflow="auto";
      this.loaded = true;
      var end = new Date().getTime();
      //this.log("build ok .. " + (end - start));
    }
  },

  _getEl:function(){
    if(this.el==null){
      //构造节点dom
      var nel = this.root._getEl();

      this.el=Builder.node("div",{
        "class":"pie-tree"+(pie.isIE()?" pie-ie":"")
      },nel);

      Event.observe(this.el,"mousemove",function(evt){
        var id=evt.element().up('.pie-tree-node').id.sub('p-t-n-','');
        evt.stop();
        this.covered=this.getNode(id).container;
        Element.addClassName(this.covered,"cover");
      }.bindAsEventListener(this))

      Event.observe(this.el,"mouseout",function(evt){
        evt.stop();
        Element.removeClassName(this.covered,"cover");
      }.bindAsEventListener(this))

      Event.observe(this.el,"click",function(evt){
        var id=evt.element().up('.pie-tree-node').id.sub('p-t-n-','');
        evt.stop();
        this.getNode(id).select();
      }.bindAsEventListener(this));

      Event.observe(this.el,"dblclick",function(evt){
        var id=evt.element().up('.pie-tree-node').id.sub('p-t-n-','');
        evt.stop();
        this.getNode(id).toggle();
      }.bindAsEventListener(this));
    }

    return this.el;
  },

  //增加新节点并高亮展现
  append:function(nodeid,nodeoptions){
    var parent=this.getNode(nodeoptions.parent_id)||this.root;
    this.log(parent.id+":"+parent.childloaded)
    if(this.loader&&!parent.childloaded){
      if(parent.hasChild()){
        //this.log("分支1A");
        parent.expand(function(){
          var node=this.getNode(nodeid);
          this.__appendHighlight(node);
        }.bind(this));
      }else{
        this.log("分支1B");
        parent.leaf=false;
        parent.expand(function(){
          parent.updateBuild();
          var node=this.getNode(nodeid);
          this.__appendHighlight(node);
        }.bind(this));
      }
    }else{
      var node=this.addNode(nodeid,nodeoptions);
      if(node){
        //this.log("分支2A")
        parent.expand();  //此时无异步事件
        parent.updateBuild();
        this.__appendHighlight(node);
      }else{
        //this.log("分支2B")
        node=this.getNode(nodeid);
        this.__appendHighlight(node);
      }
    }
  },
  __appendHighlight:function(node){
    this.log("highlight "+node.id)
    if (this.animate)
      new Effect.Highlight(node.container, {
        duration: 2.0,
        afterFinishInternal:function(){
          $(node.container).setStyle({
            backgroundImage: '',
            backgroundColor: ''
          });
        }.bind(this)
      });
    return node;
  }
}

pie.tree.JSONLoader = Class.create();
pie.tree.JSONLoader.prototype = {
  initialize: function(options){
        options = options || {};

    //日志
    this.log = function(){};//new pie.Logger().get("debugger");

    //特征参数

    //模型名称
    this.key = options.key;
    //模型上的“标题”字段名称
    this.namekey = options.namekey||"name";

    this.url = options.url;

    //运行时参数
    this.json={};
  },
  request:function(callback,nodeid){
    new Ajax.Request(this.url+".json?node="+(nodeid||''),{
      method:"get",
      onSuccess:callback.bind(this)
    })
  },
  load:function(node,callback){
    $(node.iconel).addClassName("pie-tree-loading");
    this.request(function(trans){
      var json=trans.responseJSON;
      json.each(function(node){
        var nd=$H(node).get(this.key);
        this.tree.addNode(nd.id,nd);
      }.bind(this));
      node._loadChildEls();
      $(node.iconel).removeClassName("pie-tree-loading");
      node.expanded=true;
      node.__expand_show();
      callback=callback||function(){};
      callback();
    }.bind(this),node.id);
  },
  loadRoot:function(){
    var tree=this.tree;
    tree.panel.addClassName("pie-tree-panel-loading");
    //加载所有一级子节点
    this.request(function(trans){
      var json=trans.responseJSON;
      json.each(function(node){
        var nd=$H(node).get(this.key)
        tree.addNode(nd.id,nd);
      }.bind(this));
      tree._load();
      tree.root._loadChildEls();
      tree.root.expand();
      tree.panel.removeClassName("pie-tree-panel-loading");
    }.bind(this));
  }
}