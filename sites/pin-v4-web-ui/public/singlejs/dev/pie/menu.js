/** pielib Menu version 0.2e
 *  (c) 2006-2008 MindPin.com - songliang
 *  
 *  require:
 *  prototype.js ver 1.6.0.1
 *  builder.js
 *  
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

/*
 * 07年写的代码，现在看比较烂，抽时间重构
 **/

//---Menu code begin
pie.html.Menu=Class.create({
  initialize:function(options){
    //check
    options=options||{};

    //construct
    this.options=options;

    this.items=[];

    //this._el 用于保存菜单dom
    this._el = null;
    this.caller=null;

    this.loaded=false;

    this.handles = [];

    //打开方式，默认是右键.
    this.on=options.on||"contextmenu";
    //关闭方式，默认是任何点击.
    this.closeon=options.closeon||"anyclick";

    //宽度，默认是100.
    this.width = parseInt(options.width)||100;
    this.line_height = parseInt(options.line_height)||20;
    //宽高度修正值，根据css来说，默认是4px
    this.width_diff = 4;
    this.height_diff = 4;

    //observer
    this.observer=$(options.observer||document.body);

    this.afterload=options.afterload||function(){};

    this.log = function(){};
    //this.log = new pie.Logger().get("debugger");
  },

  KIND:{
    HASH:'hash',
    DOM:'dom'
  },

  //caller 参数用于把一个菜单绑定到多个dom上的情况
  //mindmap_editor中有这种情况
  append:function(dom,at,caller){
    var handle = {'dom':dom,'at':at};

    this.handles.push(handle);

    //出现位置，默认是鼠标光标位置.
    at = at||"pointer";

    //this.on bind
    //只有mouseover比较特殊呢
    switch(this.on){
      case "mouseover":{
        $(dom).observe("mouseover",function(evt){
          evt.stop();
          var to_el=evt.toElement;var from_el=evt.fromElement;
          if((el==to_el)&&(!el.contains(from_el))){ //TODO 这里好像有点问题 再说吧
            this.load(handle,caller);
          }
        }.bindAsEventListener(this));
      }break;

      case "contextmenu":
      default:{
        $(dom).observe(this.on, function(evt){
          evt.stop();
          if($(dom).hasClassName('menu-opened')){
            this.unload();
          }else{
            $$('ul.p_h_m').each(function(m){$(m).remove();})
            $$('.menu-opened').each(function(x){$(x).removeClassName('menu-opened')})
            this.load(handle,caller,evt);
            $(dom).addClassName('menu-opened');
          }
        }.bind(this));
      }
    }

    //this.closeon bind
    switch(this.closeon){
      case "out":{
        $(dom).observe("mouseout",function(evt){
          evt.stop();
          var te=evt.toElement;
          //mouse is out of this._el?
          if (this._el) {
            if (!dom.contains(te) && !(this._el.contains(te))) {
              this.unload();
            }
          }
        }.bind(this));
      }break;

      case "anyclick":
      default:{}
    }
  },

  //Add item into Menu
  add:function(title,itemoptions){
    itemoptions=itemoptions||{};
    itemoptions.title=(itemoptions.title||title).escapeHTML();
    itemoptions.kind = this.KIND.HASH;
    this.items.push(itemoptions);
    return this;
  },

  //Add dom into Menu
  add_dom:function(dom,itemoptions){
    itemoptions=itemoptions||{};
    itemoptions.kind = this.KIND.DOM;
    itemoptions.dom = dom;
    this.items.push(itemoptions);
    return this;
  },

  //Remove item from Menu
  //By index or by title. Revmove the first founded when there is many same title;
  remove:function(i){
    if(typeof i=="number"){
      this.items=this.items.without(this.items[i])
    }else if(typeof i =="string"){
      this.items.each(function(item){
        if(item.title==i){
          this.items=this.items.without(item);
          throw $break;
        }
      }.bind(this));
    }else{
      this.items=this.items.without(i);
    }
  },

  load:function(handle,caller,evt){
    setTimeout(function(){
      //Create a Element , if it is not exist
      this.caller=caller;
      
      if(this._el){
        this.log("load menu cache");
      }else{
        this.log("create menu element");

        var m = this._build_ul_dom();

        this.items.each(function(item){
          var menuitem  = this._build_li_dom(item);

          //bind event
          item.func = item.func||function(){};

          menuitem
          .observe("mouseover",function(){
            Element.addClassName(menuitem,"item-mouseover");
          })
          .observe("mouseout",function(){
            Element.removeClassName(menuitem,"item-mouseover");
          })
          .observe("mousedown",function(evt){evt.stop();})
          .observe("contextmenu",function(evt){evt.stop();})
          .observe("click",function(evt){
            evt.stop();
            Element.removeClassName(menuitem,"item-mouseover");
            item.func.bind(this.caller)();
            this.unload();
          }.bindAsEventListener(this))
          
          $(m).insert(menuitem);
          item.li_el = menuitem;

        }.bind(this));

        this._unload_on_mousedown();

        this._el=m;
      }

      //append to observer
      var position = this._getPosition(handle,evt)
      this._append_to_observer(position.x,position.y);
    }.bind(this),0)
  },

  _build_li_dom:function(item){
    switch(item.kind){
      case this.KIND.HASH:{
        return $(Builder.node("li",{
          "class":item.func?"has_event":"no_event"
        },item.title));
      }break;
      case this.KIND.DOM:{
        return $(Builder.node("li",{
          "class":"dom"
        },[$(item.dom).show()]));
      }break;
    }
  },

  _build_ul_dom:function(){
    return $(Builder.node("ul", {
      id:Math.random(),
      "class": "p_h_m",
      "style":"width:"+this.width+"px;"
    }));
  },

  _unload_on_mousedown:function(){
    document.observe("mousedown",this.unload.bind(this));
  },

  _init_show_flag:function(){
    this.items.each(function(i){
      if(i.flag && !i.flag()){
        $(i.li_el).hide(); //2008-12-25 加入一个判断某菜单项是否显示的标志
      }else{
        $(i.li_el).show();
      }
    }.bind(this));
  },

  _append_to_observer:function(x,y){
    this._el.style.left = x+"px";
    this._el.style.top = y+"px";
    this.observer.appendChild(this._el);
    this.afterload();
    this.loaded = true;
  },

  _total_width:function(){
    return this.width + this.width_diff;
  },

  _total_height:function(){
    return this.items.length * this.line_height + this.height_diff;
  },

  _getPosition:function(handle,evt){
    var dom = handle.dom , at = handle.at;
    var x;
    var y;

    var oof=Element.cumulativeOffset(this.observer.parentNode);
    var ox=oof.left;
    var oy=oof.top;
    //默认情况下 observer是body 所以 ox oy 默认都是 0
    var co,dim,cso;

    switch(at){
      case "bottom":
      case "bottom_left":{
          co = dom.cumulativeOffset();
          cso = dom.cumulativeScrollOffset();
          dim = dom.getDimensions();
          x = co.left - cso.left - ox;
          y = co.top - cso.top + dim.height-oy;
          break;
        }
      case "bottom_center":{
        co = dom.cumulativeOffset();
        cso = dom.cumulativeScrollOffset();
        dim = dom.getDimensions();
        x = co.left - cso.left + (dim.width-this.width)/2-ox;
        y = co.top - cso.top + dim.height-oy;
        break;
      }
      case "bottom_right":{
        co = dom.cumulativeOffset();
        cso = dom.cumulativeScrollOffset();
        dim = dom.getDimensions();
        x = co.left - cso.left + dim.width - this._total_width();
        y = co.top - cso.top + dim.height;
        //3.13 特殊情况处理 菜单超出屏幕下边缘
        var screen_height = document.viewport.getHeight();
        var total_height = this._total_height()
        var menu_bottom = y + total_height;
        if(menu_bottom > screen_height){
          y = co.top - cso.top - total_height;
        }
        break;
      }
      case "":
      case "pointer":
      default:{
        x=Event.pointerX(evt);
        y=Event.pointerY(evt);
        break;
      }
    }
    this.log("x:"+x+",y:"+y);
    return {"x":x,"y":y};
  },

  //Remove all Menu dom from document
  unload:function(){
    if(this.loaded) {
      this._el.remove();
      this.loaded = false;
      this.handles.each(function(handle){handle.dom.removeClassName('menu-opened')});
    }
  }
});
//---Menu code end