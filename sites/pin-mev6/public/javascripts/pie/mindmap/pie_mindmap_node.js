pie.mindmap.Node = Class.create({
  initialize: function(options,parent){
    //options check
    options = options || {};
    Object.extend(this, options);

    if(this.revision != null){
      //初始化导图的 revision 值
      this.root         = this;
      this.map          = parent;
      this.revision     = this.revision || 0;
      this.map.revision = {
        local   : this.revision ,
        remote  : this.revision
      }
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
    this.children.each(function(child,index){
      var child_node = new pie.mindmap.Node(child,this);
      if(index > 0){
        child_node.prev = _children[index-1];
        _children[index-1].next = child_node;
      }
      child_node.index = index;
      _children.push(child_node);
    }.bind(this));
    this.children = _children;

    this.dirty = true;

    try{
      this.map.nodes.set(this.id,this);
    }catch(e){alert(e)}

    this._build_container_dom();
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

  //递归地缓存节点尺寸信息
  cache_dimensions:function(){
    if(this.width == null){
      Object.extend(this, this.el.getDimensions());
      this.children.each(function(cld){
        cld.cache_dimensions();
      }.bind(this));
    }
  },

  _bindCommonEvents:function(){
    //令节点不可选择
    this.el.makeUnselectable();

    //绑定鼠标滑过事件，可以将事件上提，改成mousemove事件以优化——jerry
    this.el.observe("mouseover",function(){
      this.el.addClassName('over');
    }.bind(this))
    .observe("mouseout",function(){
      this.el.removeClassName('over');
    }.bind(this));

    //绑定折叠点相关事件，同样可以上提以优化
    var fel=this.folder.el;
    fel.observe("mouseover",function(){
      fel.addClassName('over');
    }.bind(this))
    .observe("mouseout",function(){
      fel.removeClassName('over');
    }.bind(this))
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
      map.focus.el.removeClassName('selected');
      //如果切换节点时正处于note编辑状态，则终止note编辑，并提交
      if(map.focus!=this && map.is_on_note_edit_status){
        map._node_note_editor.onNoteEditEnd();
      }
    }
    map.focus=this;
    this.el.addClassName('selected');

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
    return this.el.hasClassName('selected');
  },

  get_bgcolor:function(){
    return this.bgcolor;
  },
  get_textcolor:function(){
    return this.textcolor;
  },
  set_bgcolor:function(bgcolor,textcolor){
    this.bgcolor = bgcolor;
    this.textcolor = textcolor;
    jQuery(this.el).css('background-color',bgcolor);
    jQuery(this.nodetitle.el).css('color',textcolor);
  }
});


pie.mindmap_node_build_dom_module = {
  _build_container_dom:function(){
    try{
      if (this.el == null) {

        this.__build_nodeimg();
        this.__build_noteicon();
        this.__build_nodetitle();
        this.__build_nodebody();

        this.el = $(Builder.node("div", {
          id:this.id,
          "class": (this.root==this ? "root" : "node"),
          "style":"position:absolute;background-color:"+this.bgcolor+";color:"+this.textcolor+";"
        },[this.nodeimg.el||[],this.nodebody.el]));

        this.folder={
          id:"f_"+this.id,
          el:$(Builder.node("div", {
            "class": this.closed ? "foldhandler plus" : "foldhandler minus",
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
          this.content.el.insert(child.container.el);
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

  __build_nodeimg:function(){
    this.nodeimg={};
    
    if (this.image) { //这个判断方式不靠谱，需要修改JSON
      this.image.el = $(Builder.node("img",{
        'src'    : this.image.url,
        'height' : this.image.height,
        'width'  : this.image.width
      }))
      this.nodeimg = {
        el: $(Builder.node("div", {
          "class": "nodeimg"
        },this.image.el))
      }
    }
  },

  __build_noteicon:function(){
    this.noteicon={};
    
    if(this.note!="" && this.note!='<br>' && this.note!='<br/>'){
      this.noteicon={
        el:$(Builder.node("div",{
          "class":"noteicon"
        }))
      }
    }
  },

  __build_nodetitle:function(){
    this.nodetitle={
      el:$(Builder.node("div",{
        "class":"nodetitle"
      }))
    }
    jQuery(this.nodetitle.el).html(this.formated_title());
  },

  __build_nodebody:function(){
    this.nodebody={
      el:$(Builder.node("div",{
        "class":"nodebody"
      },[this.nodetitle.el,this.noteicon.el||[]]))
    };
  }

}


pie.mindmap.Node
  .addMethods(pie.mindmap_node_build_dom_module);