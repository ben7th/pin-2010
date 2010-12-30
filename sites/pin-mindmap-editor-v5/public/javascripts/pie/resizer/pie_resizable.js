/** pielib Resizable version 0.1
 *  (c) 2006-2008 MindPin.com - songliang
 *  
 *  require:
 *  scriptaculous 1.8.1 with prototype.js ver 1.6.0.1
 *  
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

pie.Resizable=Class.create({
	log:function(){},
	scale:"free",	//free|fixed
	proxy:"none",	//none|dashed|shadow
	initialize: function(el,config){
		//被改变大小的对象
		this.el=$(el)
		.setStyle({
			"position":"relative",
			"overflow":"hidden"
		})
		.addClassName("pie-resizable");
		
		//check
		config = config ||{};
		
		this.scale = config.scale||this.scale;
		this.proxy = config.proxy||this.proxy;
		
		this.createHandle();
	},
	createHandle:function(){
		this.s_handle={
			el:$(Builder.node("div",{"class":"s-handle"}))
			.makeUnselectable()
			.observe("mouseover",this.showHandle.bind(this))
			.observe("mouseout",this.hideHandle.bind(this))
		}
		
		this.e_handle={
			el:$(Builder.node("div",{"class":"e-handle"}))
			.makeUnselectable()
			.observe("mouseover",this.showHandle.bind(this))
			.observe("mouseout",this.hideHandle.bind(this))
		}
		
		this.se_handle={
			el:$(Builder.node("div",{"class":"se-handle"}))
			.makeUnselectable()
			.observe("mouseover",this.showHandle.bind(this))
			.observe("mouseout",this.hideHandle.bind(this))
		}
		this.el.appendChild(this.s_handle.el);
		this.el.appendChild(this.e_handle.el);
		this.el.appendChild(this.se_handle.el);
		new this.DragHandle(this.s_handle.el,{resizer:this,direction:"s"});
		new this.DragHandle(this.e_handle.el,{resizer:this,direction:"e"});
		new this.DragHandle(this.se_handle.el,{resizer:this,direction:"se"});
	},
	showHandle:function(){
		this.s_handle.el.addClassName("s-handle-hover");
		this.e_handle.el.addClassName("e-handle-hover");
		this.se_handle.el.addClassName("se-handle-hover");
	},
	hideHandle:function(){
		if (!this.resizing) {
			this.s_handle.el.removeClassName("s-handle-hover");
			this.e_handle.el.removeClassName("e-handle-hover");
			this.se_handle.el.removeClassName("se-handle-hover");
		}
	},
	
	//继承了pie.drag.Base类来创建这个内部类
	//事实上pie.drag.Base类就是在实现这个类的过程中被抽取出来的
	DragHandle:Class.create(pie.drag.Base,{
		onInit:function(){
			this.resizer=this._config.resizer;
			this.direction=this._config.direction;
			this.scale=this.resizer.scale;
			this.proxy={
				type:this.resizer.proxy
			};
		},
		beforeStart:function(){
			this.resizer.resizing=true;
			
			var cursor=this.direction+"-resize";
			$(document.body).setStyle({"cursor":cursor});
			this.resizer.s_handle.el.setStyle({"cursor":cursor});
			this.resizer.e_handle.el.setStyle({"cursor":cursor});
			this.resizer.se_handle.el.setStyle({"cursor":cursor});
			
			this.cHeight = this.resizer.el.getHeight();
			this.cWidth = this.resizer.el.getWidth();
			
			if(this.proxy.type=="dashed"){
				this.proxy.el=$(Builder.node("div",{"style":"border:white dashed 1px;position:absolute;z-index:999999;"}));
				//此处将proxy.el 的长宽各减去2px以对齐，2px等于2倍的1px的边框宽度
				this.proxy.el.style.top=this.resizer.el.cumulativeOffset().top+"px";
				this.proxy.el.style.left=this.resizer.el.cumulativeOffset().left+"px";
				this.proxy.el.style.width=this.cWidth-2+"px"//parseFloat(this.proxy.el.style.width)-2 + "px";
				this.proxy.el.style.height=this.cHeight-2+"px"//parseFloat(this.proxy.el.style.height)-2 + "px";
				$(document.body).insert(this.proxy.el);
			}
		},
		onDragging:function(){
			if (this.scale == "free") {
				this.doResize();
			}
			else {
				this.doFixedResize();
			}
		},
		beforeFinish:function(){
			this.resizer.resizing=false;
			$(document.body).setStyle({"cursor":""});
			this.resizer.s_handle.el.setStyle({"cursor":""});
			this.resizer.e_handle.el.setStyle({"cursor":""});
			this.resizer.se_handle.el.setStyle({"cursor":""});
			
			if(this.proxy.el){
				var target=this.resizer.el;
				//此处取当前proxy.el的长宽并且减去(目标边框宽度-2*proxy边框宽度)px以求得结果值
				var heightoff=(target.offsetHeight-target.clientHeight-2);
				var widthoff=(target.offsetWidth-target.clientWidth-2);
				target.setStyle({
					"height":parseFloat(this.proxy.el.style.height)-heightoff+"px",
					"width":parseFloat(this.proxy.el.style.width)-widthoff+"px"
				});
			}
			
			if(this.proxy.el) this.proxy.el.remove();
		},
		doResize:function(){
			var newWidth = this.cWidth + this.distanceX;
			var newHeight = this.cHeight + this.distanceY;
			
			var target=this.proxy.el||this.resizer.el;
			
			if(this.direction=="s"){
				target.setStyle({
					"height":(newHeight>6?newHeight:6)+"px"
				});
			}
			
			if(this.direction=="e"){
				target.setStyle({
					"width":(newWidth>6?newWidth:6)+"px"
				});
			}
			
			if(this.direction=="se"){
				target.setStyle({
					"height":(newHeight>6?newHeight:6)+"px",
					"width":(newWidth>6?newWidth:6)+"px"
				});
			}
		},
		doFixedResize:function(){
			//下面的公式的推导过程花掉了我5分钟的时间
			var dX=this.distanceX;
			var dY=this.distanceY;
			var cH=this.cHeight;
			var cW=this.cWidth;
			
			var td=(dX*cW+dY*cH)/(cW*cW+cH*cH);
			var tX=td*cW;
			var tY=td*cH;
			
			var newWidth = this.cWidth + tX;
			var newHeight = this.cHeight + tY;
			
			var target=this.proxy.el||this.resizer.el;
			
			target.setStyle({
				"height":newHeight+"px",
				"width":newWidth+"px"
			});
		}
	})
});


