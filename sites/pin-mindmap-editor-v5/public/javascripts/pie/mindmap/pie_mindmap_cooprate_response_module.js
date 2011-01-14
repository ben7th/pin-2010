pie.mindmap_cooprate_response_module = {
  show_op_instance:function(json){
    var map_id       = json.map;
    var operations   = json.operations;
    var revision     = json.revision;
    var user_id      = json.user_id;
    var new_revision = json.new_revision;
    operations.each(function(oper){
      var op = oper.op;
      var params = oper.params;
      switch(op){
        case 'do_insert':{
          this._show_insert_instance(params);
          this.revision = new_revision;
        }break;
        case 'do_delete':{
          this._show_delete_instance(params);
          this.revision = new_revision;
        }break;
        case 'do_title':{
          this._show_title_instance(params);
          this.revision = new_revision;
        }break;
        default:{
          pie.log(op);
        }
      }
    }.bind(this));
  },
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

  _show_delete_instance:function(op_params){
    var node_id = op_params.node_id;
    var node = this.nodes.get(node_id);
    new Effect.Fade(node.container.el,{afterFinish:function(){
      node._remove();
      this.reRank();
    }.bind(this)});
    node.sub.dirty = true;
  },

  _show_title_instance:function(op_params){
    try{
      var node_id = op_params.node_id;
      var title = op_params.title;

      var node = this.nodes.get(node_id);
      _t = title.gsub('\\n','\n').gsub('\\\\','\\');
      node.set_title(_t);
      Object.extend(node,node.el.getDimensions());
			if(node.sub){
				node.sub.dirty = true;
			}
      this.reRank();
      new Effect.Highlight(node.el,{startcolor: '#FF6666'});
    }catch(e){
      alert(e);
    }
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
  }
})