pie.mindmap.OperationRecordFactory = Class.create({
	initialize: function(options){
    options = options || {};
		this.map = options.map;
		
		//日志
		this.log = function(){};
	},
	getInsertInstance: function(node){	
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_insert",
					"params":{"parent":node.parent.id,"index":node.index}
				}
	},
	getDeleteInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_delete"
				}
	},
	getTitleInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_title",
					"params":{"title":node.title.replace(/\\/g,"\\\\").replace(/\n/g,"\\n")}
				}
	},
	getToggleInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_toggle",
					"params":{"fold":node.fold}
				}
	},
	getImageInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_image",
					"params":node.image
				}
	},
	getMoveInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_move",
					"params":{"parent":node.parent.id,"index":node.index,"putright":node.putright?"1":"0"}
				}
	},
	getNoteInstance: function(node){
		return {	"map":this.map.id,
					"node":node.id,
					"op":"do_note",
					"params":{"note":node.note}
				}
	}
		//新增节点
//		{map:"3",node:"7",op:"do_insert",params:{parent:"6",index:0}}
//		
//		{node:"7",op:"undo_insert"}
//		
//		//删除节点（子树）
//		{map:"3",node:"9",op:"do_delete"}
//		
//		{node:"9",op:"undo_delete",params:{parent:"8",node:{"fold": "0"...}}}
//		
//		//修改标题
//		{map:"3",node:"10",op:"do_title",params:{title:"新的标题"}}
//		
//		{node:"10",op:"undo_title",params:{title:"旧的标题"}}
//		
//		//节点图片状态改变
//		{map:"3",node:"10",op:"do_image",params:{url:"http://www.example.com/new.jpg",width:"100",height:"200"}}
//		
//		{node:"10",op:"undo_image",params:{url:"http://www.example.com/old.jpg",width:"100",height:"200"}}
//		
//		//节点备注修改
//		{map:"3",node:"12",op:"do_note",params:{note:"新的备注"}}
//		
//		{node:"12",op:"undo_title",params:{note:"旧的备注"}}
//		
//		//移动节点
//		{map:"3",node:"13",op:"do_move",params:{parent:"6",index:0,putright:"1"}}
//		
//		{node:"13",op:"undo_move"},params:{parent:"7",index:1}
//		
//		//折叠展开 (没有undo)
//		{map:"3",node:"14",op:"do_toggle",params:{fold:0}}
});