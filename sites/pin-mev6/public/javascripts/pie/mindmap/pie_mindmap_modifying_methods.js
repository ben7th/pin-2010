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
  },
  remove:function(){
    // get ready
    var map = this.map;
    if(map._pause()){return;}
    if (this.is_root()){return;}

    // modify data
    // show animation effect
    map.mr_factory.data_remove(false, this)

    // after operation
    if (this.next) {this.next.select();}
    else if(this.prev) {this.prev.select();}
    else {this.parent.select();}

    // post data
    var record = map.opFactory.getDeleteInstance(this);
    map._save(record);
  },
  set_title_and_save:function(title){
    try{
      //get ready
      var map = this.map;

      // modify data
      // show animation effect
      map.mr_factory.data_title(false, this, title);

      // after operation
      this.select();

      // post data
      if(this.title != this._oldtitle) {
        var record = map.opFactory.getTitleInstance(this);
        map._save(record);
      }
    }catch(e){alert(e)}
  },

  set_image_and_save:function(image){
    try{
      //get ready
      var map = this.map;

      // modify data
      // show animation effect
      map.mr_factory.data_image(false, this, image);

      // after operation
      this.select();

      // post data
      var record = map.opFactory.getImageInstance(this);
      map._save(record);
      
    }catch(e){alert(e)}
  },

  remove_image_and_save:function(){
    try{
      //get ready
      var map = this.map;
      
      // modify data
      // show animation effect
      map.mr_factory.data_remove_image(false, this);

      // after operation
      this.select();

      // post data
      var record = map.opFactory.getRemoveImageInstance(this);
      map._save(record);

    }catch(e){alert(e)}
  }
}

pie.mindmap_node_new_child_methods = {
  //创建新节点（数据和DOM）
  _newChild:function(new_index,node_id){
    var child = this.__build_child_hash(node_id);
    this.__add_to_children(child, new_index);
    this.__add_to_html_dom(child);
    if(!this.is_root()) this.folder.el.show();
    child.sub.dirty = true;
    this.map.nodes.set(child.id,child);
    return child;
  },
  __build_child_hash:function(node_id){
    var child_hash = {
      "image"     : null,
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
    var container_dom = child.container.el;
    var target_dom;

    if(child.prev){
      target_dom = this.is_root() ? child.prev.canvas.el : child.prev.container.el;
      target_dom.insert({after: container_dom});
    }else{
      target_dom = this.content.el;
      target_dom.insert({bottom: container_dom});
    }

    child.cache_dimensions();
  }
}

pie.mindmap_node_remove_child_methods = {
  _remove:function(){
    try{
      var parent = this.parent;
      this.container.el.remove();

      parent.children = parent.children.without(this);
      parent.__tidyChildren();

      if (parent.is_root()) {
        this.canvas.el.remove();
        this.branch.el.remove();
      }else if(parent.children.length == 0){
        parent.folder.el.hide();
      }

      this.sub.dirty = true;
      this.map.nodes.unset(this.id);
    }catch(e){alert(e)}
    return this;
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
    this.folder.el.className = "foldhandler minus";
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
    this.folder.el.className = "foldhandler plus";
    this.closed = true;
  }
}

pie.mindmap.Node
  .addMethods(pie.mindmap_node_modifying_methods)
  .addMethods(pie.mindmap_node_new_child_methods)
  .addMethods(pie.mindmap_node_toggle_methods)
  .addMethods(pie.mindmap_node_remove_child_methods)