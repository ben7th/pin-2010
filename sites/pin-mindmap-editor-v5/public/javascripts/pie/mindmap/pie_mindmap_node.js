pie.mindmap.Node = Class.create({
  initialize: function(options,parent){
    this.log=function(){};
    //options check
    options = options || {};

    Object.extend(this,options);

    if(this.maxid!=null){
      this.root = this;
      this.map = parent;
      this.map.revision = this.revision || 0;
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
      jQuery(this.el).tipsy({
        gravity:jQuery.fn.tipsy.autoWE,
        title:function(){
          return this.note
        }.bind(this)
      })
    }
  },
  _bindEditEvents:function(){
    //右键菜单
    this.root.map.nodeMenu.bind(this.el,"bottom",this);
  },
  toggle:function(evt){
    var map=this.root.map;
    if(map._pause()){return;}
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
  //
  _newChild:function(index){
    var isRoot=(this==this.root);
    var child={
      "image":{"width": null, "border": null, "url": null, "height": null},
      "fold": "0",
      "note": "",
      "children":[],
      "title": "NewSubNode",
      "putright": "1",
      "id":pie.randstr()
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
  },
  do_dirty:function(){
    if(this.is_root()) return;
    this.sub.dirty = true;
  },
  is_root:function(){
    return this == this.root;
  }
});