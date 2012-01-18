pie.mindmap = pie.mindmap || {};

// 此处节点还是不分左右的。只有声明了布局方法，才有左右的区分。
pie.mindmap.base = {
  
  shared_methods : {
    is_note_blank : function(){
      return jQuery.string(this.note).blank();
    },
    
    title_html : function(){
      return jQuery.string(this.title).escapeHTML().str
        .replace(/\n/g, "<br/>")
        .replace(/\s/g, "&nbsp;")
        .replace(/>$/,  ">&nbsp;");
    },
    
    // descendants 这个单词太难记了
    houdai : function(){
      var re = [];
      jQuery.each(this.children, function(index, child){
        re = re.concat([child]).concat(child.houdai());
      });
      return re;
    },
    
    each_houdai : function(func){
      jQuery.each(this.houdai(), function(index, nd){
        func(nd);
      })
    }
  },
  
  root_methods : {
    zuxian : function(){
      return [];
    }
  },
  
  node_methods : {
    // 父辈
    zuxian : function(){
      return [this.parent].concat(this.parent.zuxian());
    },
    
    each_zuxian : function(func){
      jQuery.each(this.zuxian(), function(index, nd){
        func(nd);
      })
    }
  },
  
  init : function(R){
    var BASE = pie.mindmap.base;
    
    var root = R.data;
    
    // 梳理json-object，给每个节点声明以下keys:
    // R, parent, root, prev_node, next_node
    // 并将节点置入hash
    
    var _r = function(node, parent_node){
      R.enter(node);
      node.R = R;
      
      jQuery.extend(node, BASE.shared_methods)
      jQuery.extend(node, (null == parent_node) ? BASE.root_methods : BASE.node_methods)
      
      node.parent = parent_node;
      node.root   = root;
      
      var children = node.children;
      jQuery.each(children, function(index, child){
        _r(child, node);
        
        child.prev_node = children[index - 1] || null;
        child.next_node = children[index + 1] || null;
      });
    }
    _r(root, null);
  }
}