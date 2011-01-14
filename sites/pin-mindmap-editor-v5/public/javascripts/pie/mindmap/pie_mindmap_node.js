pie.mindmap.Node = Class.create({
  initialize: function(options,parent){
    //options check
    options = options || {};

    Object.extend(this,options);

    if(this.revision != null){
      this.root         = this;
      this.map          = parent;
      this.map.revision = this.revision || 0;
    }else{
      this.parent       = parent;
      this.root         = parent.root;
      this.map          = this.root.map;
      this.sub          = this.parent.is_root() ? this : this.parent.sub;
    }

    this.canvas = {};
    this.branch = {};
    this.left   = 0;
    this.top    = 0;

    //递归地生成子节点对象
    var _children=[];
    this.children.each(function(cld,index){
      var cldnode=new pie.mindmap.Node(cld,this);
      if(index>0){
        cldnode.prev=_children[index-1];
        _children[index-1].next=cldnode;
      }
      cldnode.index=index;
      _children.push(cldnode);
    }.bind(this));
    this.children=_children;

    this.dirty=true;
    try{
      this.map.nodes.set(this.id,this);
    }catch(e){alert(e)}
  },
  _build_container_dom:function(){
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
        Element.update(this.nodetitle.el, this.formated_title());

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

        this.folder={
          id:"f_"+this.id,
          el:$(Builder.node("div", {
            "class": this.closed ? "foldhandler_plus" : "foldhandler_minus",
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
          this.content.el.insert(child._build_container_dom());
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
        if (this.map.editmode) {
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

  simple_format:function(titlestr){
    var re = titlestr.escapeHTML().replace(/\n/g, "<br/>").replace(/\s/g, "&nbsp;").replace(/>$/, ">&nbsp;");
    return re;
  },

  set_title:function(titlestr){
    var i_title = (titlestr == '' ? ' ' : titlestr)

    Element.update(this.nodetitle.el, this.simple_format(i_title));
    //2009-1-19 某些浏览器，如IE下，textarea.value赋值时，\n会自动被替换为\r\n，这里需要替换回来
    //否则每次提交都会导致新增一行
    this.title = i_title.replace(/\r\n/g,"\n");
  },
  formated_title:function(){
    return this.simple_format(this.title);
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
      if(this.map.pause){return false;}
      fel.addClassName('foldhandler_down');
    }.bindAsEventListener(this))
    .observe("click",this.toggle.bind(this));

    //绑定节点单击选定事件
    this.el.observe("click",function(evt){
      if(Event.isLeftClick(evt) && this.is_selected()){
        this.map.edit_focus_title();
      }
      this.select();
    }.bind(this))
    .observe("contextmenu",function(){
      this.select();
    }.bind(this));

    if(pie.isIE() && this.map.editmode){
      this.el.observe("dblclick",function(evt){
        this.map.edit_focus_title();
      }.bind(this));
    }

    if(this.map.editmode){
      //note编辑器
      //safari在这里的事件绑定有问题，待修改
      try{
        Element.observe($(this.map._node_note_editor.dom),"focus",function(){
          this.map._node_note_editor.onNoteEditBegin(this)
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
    this.map.nodeMenu.bind(this.el,"bottom",this);
  },

  select:function(keep){
    var map=this.map;
    if(this.is_being_edit) return false;
    if(map.focus){
      map.stop_edit_focus_title();
      map.focus.el.removeClassName('node_selected');
      map.focus.el.removeClassName('root_selected');
      //如果切换节点时正处于note编辑状态，则终止note编辑，并提交
      if(map.focus!=this && map.is_on_note_edit_status){
        map._node_note_editor.onNoteEditEnd();
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
        map._node_note_editor.set_value('');
      }else{
        map._node_note_editor.set_value(this.note);
      }
    }

    return this;
  },
  getPrevCousin:function(){
    var p=this;
    var i=0;
    do{
      var pp=p;
        while(pp = pp.prev){
        if(pp.sub.pos == p.sub.pos){
          break;
        }
      }
      if (pp) {
        while(i>0){
          i--;
          if((pp.children.length>0) && !pp.closed){
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
        if(pp.sub.pos == p.sub.pos){
          break;
        }
      }
      if(pp){
        while(i>0){
          i--;
          if((pp.children.length>0) && !pp.closed){
            pp=pp.children.first();
          }
        }
        return pp;
      }
      i++;
    }while(p=p.parent);
    return this;
  },

  remove:function(){
    if(this.map._pause() || this == this.root){
      return false;
    }

    this._remove();

    var record = this.map.opFactory.getDeleteInstance(this);
    this.map._save(record);
    this.sub.dirty=true;
    this.map.reRank();
  },

  _remove:function(){
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
  },
  put_on_right:function(){
    return this.pos == 'right' || this.pos == null
  },
  is_selected:function(){
    return this.el.hasClassName('node_selected') || this.el.hasClassName('root_selected');
  }
});


pie.mindmap_node_modifying_methods = {
  createNewSibling:function(){
    // get ready
    var map = this.map;
    if(map._pause()){return;}
    if (this.is_root()) {return;}

    // modify data
    // show animation effect
    var new_index = this.index + 1;
    var parent    = this.parent;
    var child = map.mr_factory.data_insert(false, new_index, parent);

    // after operation
    child.select();

    // post data
    var record = map.opFactory.getInsertInstance(child);
    map._save(record);

  },
  createNewChild:function(){
    // get ready
    var map = this.map;
    if(map._pause()){return;}

    // modify data
    // show animation effect
    var new_index = this.children.length;
    var parent    = this;
    var child = map.mr_factory.data_insert(false, new_index, parent);

    // after operation
    child.select();

    // post data
    var record = map.opFactory.getInsertInstance(child);
    map._save(record);
  }
}

pie.mindmap_node_new_child_methods = {
  //创建新节点（数据和DOM）
  _newChild:function(new_index,node_id){
    var child = this.__build_child_hash(node_id)
    this.__add_to_children(child, new_index);
    this.__add_to_html_dom(child);
    if(!this.is_root()) this.folder.el.show();
    child.sub.dirty = true;
    this.map.nodes.set(child.id,child);
    return child;
  },
  __build_child_hash:function(node_id){
    var child_hash = {
      "image"     : {"url":null, "width":null, "height":null},
      "closed"    : false,
      "note"      : "",
      "children"  : [],
      "title"     : "NewSubNode",
      "pos"       : "right",
      "id"        : node_id || pie.randstr()
    };

    if(this.is_root()){
      var focus = this.map.focus;
      if(focus.parent == this){
        child_hash.pos = focus.pos;
      }
    }

    return new pie.mindmap.Node(child_hash,this);
  },
  __add_to_children:function(child, new_index){
    var part1 = this.children.slice(0, new_index);
    var part2 = this.children.slice(new_index);

    child.prev = part1.last();
    if(child.prev) child.prev.next = child;

    child.next = part2.first();
    if(child.next) child.next.prev = child;

    part1.push(child);
    this.children = part1.concat(part2);

    this.children.each(function(chd, idx){
      chd.index = idx;
    }.bind(this));
  },
  __add_to_html_dom:function(child){
    var container_dom = child._build_container_dom();
    var target_dom;

    if(child.prev){
      target_dom = this.is_root() ? child.prev.canvas.el : child.prev.container.el;
      target_dom.insert({after: container_dom});
    }else{
      target_dom = this.content.el;
      target_dom.insert({bottom: container_dom});
    }

    child._cacheDimensions();
  }
}

pie.mindmap_node_toggle_methods = {
  toggle:function(force){
    // get ready
    var map = this.map;
    if(!force && map._pause()){return;}

    // modify data
    this._toggle();
    this.sub.dirty=true;

    // show animation effect
    map.reRank();

    // post data
    var record = map.opFactory.getToggleInstance(this);
    map._save(record);
  },
  _toggle:function(){
    if(this.closed){
      this._expand();
    }else{
      this._collapse();
    }
    this.content.el.toggle();
  },
  _expand:function(){
    this.folder.el.className = "foldhandler_minus";
    this.closed = false;
  },
  _collapse:function(){
    //当focus在子孙节点中时，选中当前节点
    var p=this.map.focus;
    if(p)
    while(p!=this.root){
      if(p.parent==this){
        this.select();
        break;
      }
      p=p.parent;
    }
    this.folder.el.className = "foldhandler_plus";
    this.closed = true;
  }
}

pie.mindmap.Node
  .addMethods(pie.mindmap_node_modifying_methods)
  .addMethods(pie.mindmap_node_new_child_methods)
  .addMethods(pie.mindmap_node_toggle_methods)
