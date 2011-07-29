pie.drag.Simple=Class.create(pie.drag.Base,{
	onInit:function(){},
	beforeStart:function(){
		this.ileft = parseInt(this.el.style.left||0);
		this.itop = parseInt(this.el.style.top||0);
	},
	onDragging:function($super){
		var newLeft = this.ileft + this.distanceX;
    var newTop = this.itop + this.distanceY;
		this.el.setStyle({
			"top":newTop+"px",
			"left":newLeft+"px"
		})
	},
	beforeFinish:function(){}
});

pie.drag.Page=Class.create(pie.drag.Base,{
	onInit:function(){
		this.beforeDrag=this._config.beforeDrag||function(){};
	},
	isReady:function(){
		if(this.evtel.tagName=="INPUT"||this.evtel.tagName=="TEXTAREA") return false;
	},
	beforeStart: function(){
		this.beforeDrag();
		this.parent=this.el.parentNode;
		this.scrollX = this.parent.scrollLeft;
		this.scrollY = this.parent.scrollTop;
	},
	onDragging:function(){
		var newLeft = this.scrollX - this.distanceX;
    var newTop = this.scrollY - this.distanceY;
		this.parent.scrollLeft = newLeft;
		this.parent.scrollTop = newTop;
		this.xoff = newLeft;
		this.yoff = newTop;
	}
});