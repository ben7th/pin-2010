pie.mindmap.NodeNoteEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
    this._build_editor_dom();
	},

  _build_editor_dom:function(){
    // mindmap-note-edit
    this.dom = $('mindmap-note-edit');
  },

  value:function(){
    return this.dom.value;
  },

  set_value:function(note_text){
    this.dom.value = note_text || '';
  },

	onNoteEditBegin:function(){
		var map = this.map
		if(this._can_edit_node()){
			map.is_on_note_edit_status = true;
			if(this.peee) this.peee.stop();
			this.peee = new PeriodicalExecuter(this.onNoteChange.bind(this), 5);
			map.focus.notecache = this.value();
		}
	},
	onNoteEditEnd:function(){
		var map = this.map;
		this.onNoteChange();
		this.peee.stop();
		map.is_on_note_edit_status=false;
		this.dom.blur();
		if(!pie.isIE()){
			window.focus();
		}
	},
	onNoteChange:function(){
		var map = this.map;
		if(map.editmode && map.focus){
			var node=map.focus;
			var note=this.value();
			if(note==node.notecache) return false;
			node.notecache = note;
			if(map.id){
				node.note = note;
				var record = map.opFactory.getNoteInstance(node);
				map._save(record);
			}
			if(note!=""&&note!='<br>'){
				if (!node.noteicon.el) {
					node.noteicon={
						el:$(Builder.node("div",{
							"class":"noteicon"
						}))
					}
					node.nodetitle.el.insert({After:node.noteicon.el});
					node.width += 10;
					node.sub.dirty = true;
					node.map.reRank();
				}
			}else{
				if(node.note==""||node.note=="<br>"){
					if(node.noteicon.el){
						Element.remove(node.noteicon.el);
						node.noteicon={};
					}
				}
				node.width -= 10;
				node.sub.dirty=true;
				node.map.reRank();
			}
		}
	},

  _can_edit_node:function(){
    return this.map.editmode && this.map.focus;
  }
});