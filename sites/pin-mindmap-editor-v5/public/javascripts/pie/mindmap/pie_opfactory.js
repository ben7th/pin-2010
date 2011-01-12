pie.mindmap.OperationRecordFactory = Class.create({
	initialize: function(options){
    options = options || {};
		this.map = options.map;
		//日志
		this.log = function(){};
	},
  
	getInsertInstance: function(node){	
		return {
      "op":"do_insert",
      "params":{
        "parent_id":node.parent.id,
        "index":node.index,
        "new_node_id":node.id
      }
    }
	},
	getDeleteInstance: function(node){
		return {
      "op":"do_delete",
      "params":{
        "node_id":node.id
      }
    }
	},
	getTitleInstance: function(node){
		return {
      "op":"do_title",
      "params":{
        "node_id":node.id,
        "title":node.title.replace(/\\/g,"\\\\").replace(/\n/g,"\\n")
      }
    }
	},
	getToggleInstance: function(node){
		return {
      "op":"do_toggle",
      "params":{
        "node_id":node.id,
        "closed":node.closed
      }
    }
	},
	getImageInstance: function(node){
		return {
      "op":"do_image",
      "params":{
        "node_id":node.id,
        "image":node.image
      }
    }
	},
  getRemoveImageInstance: function(node){
    return {
      "op":"do_rm_image",
      "params":{
        "node_id":node.id
      }
    }
  },
	getNoteInstance: function(node){
		return {
      "op":"do_note",
			"params":{
        "node_id":node.id,
        "note":node.note
			}
    }
	},
	getMoveInstance: function(node){
		return {
      "op":"do_move",
      "params":{
        "parent_id":node.parent.id,
        "node_id":node.id,
        "index":node.index,
        "pos":node.pos
      }
    }
	}
});