pie.mindmap_cooprate_response_module = {
  show_op_instance:function(json){
//    var map_id              = json.map;
//    var user_email          = json.user;
    var oper                = json.op;
    var new_revision_remote = json.new_rev_remote;
    
    var op = oper.op;
    var params = oper.params;
    switch(op){
      case 'do_insert':{
        this._show_insert_instance(params);
      }break;
      case 'do_delete':{
        this._show_delete_instance(params)
      }break;
      case 'do_title':{
        this._show_title_instance(params);
      }break;
      case 'do_image':{
        this._show_image_instance(params);
      }break;
      default:{
        pie.log(op);
      }
    }

    this.revision.remote = new_revision_remote;
    pie.log(this.revision);
  },
  //1.12
  _show_insert_instance:function(op_params){
    try{
      var parent_id   = op_params.parent_id;
      var index       = op_params.index;
      var new_node_id = op_params.new_node_id;
      //插入节点

      // modify data
      // show animation effect
      var new_index = index;
      var parent    = this.nodes.get(parent_id);
      this.mr_factory.data_insert(true, new_index, parent, new_node_id);

    }catch(e){
      alert(e);
    }
  },
  //1.12
  _show_delete_instance:function(op_params){
    var node_id = op_params.node_id;
    var node = this.nodes.get(node_id);
    this.mr_factory.data_remove(true, node);
  },
  
  _show_title_instance:function(op_params){
    var node_id = op_params.node_id;
    var title = op_params.title;

    var node = this.nodes.get(node_id);
    this.mr_factory.data_title(true, node, title);
  },

  _show_image_instance:function(op_params){
    var node_id = op_params.node_id;
    var image = op_params.image;
  }
}


pie.mindmap.ModifyingResponseFactory = Class.create({
	initialize: function(options){
    options = options || {};
		this.map = options.map;
	},
  data_insert:function(other_coop, new_index, parent, new_node_id){

    // modify data
    if(parent.closed) parent.toggle(true); //先展开，否则宽高计算不准确
    var child = parent._newChild(new_index,new_node_id);

    // show animation effect
    this.map.reRank();
    
    if(other_coop){
      new Effect.Highlight(child.el,{startcolor:'#FF6666', duration:3});
      return null;
    }else{
      new Effect.Pulsate(child.el,{duration:0.4});
      return child;
    }
  },
  data_remove:function(other_coop, node){
    if(other_coop){
      new Effect.Highlight(node.container.el,{startcolor:'#FF6666'});
      new Effect.Fade(node.container.el,{afterFinish:function(){
        node._remove();
        this.map.reRank();
      }.bind(this)});
    }else{
      node._remove();
      this.map.reRank();
    }
  },
  data_title:function(other_coop, node, title){
    node.set_title(title)
		node.el.show();

		//先去掉节点上的“被选择”样式，然后再计算宽高，才不会有错误
		node.el.removeClassName('selected');
		Object.extend(node,node.el.getDimensions());

		if(node.title == node._oldtitle) return;
    
    node.do_dirty();
    this.map.reRank();
    
    if(other_coop){
      new Effect.Highlight(node.el,{startcolor: '#FF6666'});
    }
  },
  data_image:function(other_coop, node, image){
    if(node.image){
      if (node.image.jq) {node.image.jq.remove();}
    }
    node.image = image;
    node.__build_nodeimage();

    jQuery(node.nodebody.el).before(node.image.jq);
    
    node.re_rank();

    if(other_coop){
      new Effect.Highlight(node.el,{startcolor: '#FF6666'});
    }
  },
  data_remove_image:function(other_coop, node){
    if(node.image){
      if (node.image.jq) {node.image.jq.remove();}
    }
    node.image = null;

    node.re_rank();

    if(other_coop){
      new Effect.Highlight(node.el,{startcolor: '#FF6666'});
    }
  },
  data_note:function(other_coop, node, note){
    if(node.noteicon){
      if(node.noteicon.jq) {node.noteicon.jq.remove();}
    }
    
    node.note = note;
    node.__build_noteicon();

    if(node.noteicon.jq){
      jQuery(node.nodetitle.el).after(node.noteicon.jq);
    }

    node.re_rank();

    if(other_coop){
      new Effect.Highlight(node.el,{startcolor: '#FF6666'});
    }
  }
})