/** pielib Controller version 0.1
 *  (c) 2006-2008 MindPin.com - songliang
 *  
 *  require:
 *  scriptaculous 1.8.1 with prototype.js ver 1.6.0.1
 *  
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

pie.drag={};

/**
 * pie.drag.Base
 * 
 * 	包装了几乎所有与鼠标拖拽相关的方法（移动元素，改变元素大小，鼠标动作）之中涉及到
 * 的基本代码，以便于实现具体方法时减少编码量和出错可能。这个类已经封装了事件初始化，事
 * 件销毁，移动过程中鼠标信息获取等一些必要的操作，使用时只需要用Class.create()继承这
 * 个基类，填充几个“接口方法”之后就可以实现自定义的各种功能，具体说明如下：
 * </p>
 *  
 * 	创建自定义类：
 *	MyDraggable = Class.create(pie.drag.Base,{
 * 		attribute:"...",
 * 		...
 * 		onInit:function(){...},
 * 		beforeStart:function(){...},
 * 		onDragging:function(){...},
 * 		beforeFinish:function(){...}
 *	});
 *	
 *	使用自定义类：
 *  new MyDraggable(element,config={...}) element是被拖拽的目标对象，config中可任意传递参数
 * 
 *  “接口方法”说明：
 *  
 *	onInit:
 *	初始化时initialize()方法中间执行的方法，此处主要可以进行一些参数的设置
 *	此处可以通过this._config句柄来获取传入的config对象
 *
 *	beforeStart:
 *  触发拖拽过程时执行的方法，用来进行一些初始数据的获得，如某些DOM元素这一瞬间的状态等
 *  此处可通过this.cX,this.cY获得鼠标的初始坐标
 *  
 *  onDragging:
 *  拖拽过程中不断执行的方法，一般用来产生移动、缩放、轨迹绘制等特殊效果
 *  此处可通过this.cX，this.cY获得鼠标的初始坐标
 *  可以通过this.newX，this.newY获得鼠标的当前坐标
 *  可以通过this.distanceX，this.distanceY获得鼠标的位移量
 *  
 *  beforeFinish：
 *  拖拽过程结束时执行的方法，可用来执行一些后续处理的函数
 *  
 *  另外随时可以通过this.ondrag来获取拖放是否正在进行
 *  
 *  具体例子可以参考pie.drag.Simple
 */
pie.drag.Base=Class.create({
	initialize:function(el,config){
		this.el=$(el);
		this._config=config;

		this.onInit();
		
		//Handle
		this.mdh=this.mouseDownHandle.bindAsEventListener(this);
		this.mmh=this.mouseMoveHandle.bindAsEventListener(this);
		this.muh=this.mouseUpHandle.bindAsEventListener(this);

		//bind Handle
		this.el.observe("mousedown",this.mdh);
	},
	mouseDownHandle:function(evt){
		this.evtel=evt.element();
		if(this.isReady()==false) return false;
		evt.stop();
		if(!evt.isLeftClick()) return false;
		
		this.ondrag=false;
		
		//事件绑定
		document.observe("mousemove",this.mmh);
		document.observe("mouseup",this.muh);
		
		//初始坐标
	    this.cX = evt.pointerX();
	    this.cY = evt.pointerY();
		
		this.newX = this.cX;
		this.newY = this.cY;

		this.beforeStart();
		
		this.moveTimer = setInterval(function(){
			this.moveListener();
		}.bind(this), 10);
	},
	mouseMoveHandle:function(evt){
	    evt.stop();
		if (this.el == null) return false;
		this.ondrag = true;
		this.newX = evt.pointerX();
	    this.newY = evt.pointerY();
	},
	moveListener:function(){
    	if(!this.ondrag) return false;
		this.distanceX = this.newX - this.cX;
	    this.distanceY = this.newY - this.cY;

		this.onDragging();
	},
	mouseUpHandle:function(evt){
		if (this.ondrag) {
			this.ondrag = false
		};
		
		if(!this.el) return false;
		
		//停止绑定
		document.stopObserving("mousemove", this.mmh);
		document.stopObserving("mouseup", this.muh);

		this.beforeFinish();
		
		if(this.moveTimer) {
			clearInterval(this.moveTimer);
			this.moveTimer = null;
		}
	},
	onInit:function(){},
	isReady:function(){return true},
	beforeStart:function(){},
	onDragging:function(){},
	beforeFinish:function(){}
});

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