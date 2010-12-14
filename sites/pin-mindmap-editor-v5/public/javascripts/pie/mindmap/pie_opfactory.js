pie.mindmap.OperationRecordFactory = Class.create({
	initialize: function(options){
    options = options || {};
		this.map = options.map;
		//日志
		this.log = function(){};
	},
  
	getInsertInstance: function(node){	
		return {
      "map":this.map.id,
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
      "map":this.map.id,
      "op":"do_delete",
      "params":{
        "node_id":node.id
      }
    }
	},
	getTitleInstance: function(node){
		return {
      "map":this.map.id,
      "op":"do_title",
      "params":{
        "node_id":node.id,
        "title":node.title.replace(/\\/g,"\\\\").replace(/\n/g,"\\n")
      }
    }
	},
	getToggleInstance: function(node){
		return {
      "map":this.map.id,
      "op":"do_toggle",
      "params":{
        "node_id":node.id,
        "fold":node.fold
      }
    }
	},
	getImageInstance: function(node){
		return {
      "map":this.map.id,
      "op":"do_image",
      "params":{
        "node_id":node.id,
        "image":node.image
      }
    }
	},
	getNoteInstance: function(node){
		return {
      "map":this.map.id,
      "op":"do_note",
			"params":{
        "node_id":node.id,
        "note":node.note
			}
    }
	},
	getMoveInstance: function(node){
		return {
      "map":this.map.id,
      "op":"do_move",
      "params":{
        "parent_id":node.parent.id,
        "node_id":node.id,
        "index":node.index,
        "putright":node.putright?"1":"0"
      }
    }
	}
});