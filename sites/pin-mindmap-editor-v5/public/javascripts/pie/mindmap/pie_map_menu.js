/** pielib Menu version 0.1
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

//---Menu code begin

pie.mindmap = pie.mindmap || {};

pie.mindmap.Menu=Class.create();
pie.mindmap.Menu.prototype={
  //e dom Object which the Menu will bind to
  initialize:function(options){
    //check
    options=options||{};

    //construct
    this.options=options;

    this.items=[];

    this.el=null;
    this.binder=null;

    this.isload=false;

    //打开方式，默认是右键.
    this.on=options.on||"contextmenu";
    //关闭方式，默认是任何点击.
    this.closeon=options.closeon||"anyclick";
    //宽度，默认是100.
    this.width=parseInt(options.width)||120;

    //边框，默认是1px.
    this.border=parseInt(options.border)||1;

    this.height=2*this.border;

    this.lh=20;

    //observer
    this.observer=$(options.observer||document.body);

    this.afterload=options.afterload||function(){};

    this.log = function(){};
  },

  bind:function(sayer,at,binder){
    sayer=$(sayer);

    //出现位置，默认是鼠标光标位置.
    at=at||"pointer";

    //this.on bind
    switch(this.on){
      case "mouseover":{
        Event.observe(sayer,"mouseover",function(evt){
          evt.stop();
          var te=evt.toElement;
          var fe=evt.fromElement;
          if((el==te)&&(!el.contains(fe))){
                        var p = this._getPosition(evt, sayer, at);
                        this.load(p.x, p.y, binder);
          }
        }.bindAsEventListener(this));
        break;
      }

      case "contextmenu":
      default:{
        Event.observe(sayer, this.on, function(evt){
          evt.stop();
          var p = this._getPosition(evt,sayer,at);
          this.load(p.x, p.y, binder);
        }.bindAsEventListener(this));
      }
    }

    //this.closeon bind
    switch(this.closeon){
      case "out":{
        Event.observe(sayer,"mouseout",function(evt){
            evt.stop();
          var te=evt.toElement;
          //mouse is out of this.e?
          if (this.el) {
            if (!sayer.contains(te) && !(this.el.contains(te))) {
              this.unload();
            }
          }
        }.bindAsEventListener(this));
        break;
      }

      case "anyclick":
      default:{}
    }
  },

  //Add item into Menu
  addItem:function(title,itemoptions){
    itemoptions=itemoptions||{};
    itemoptions.title=(itemoptions.title||title).escapeHTML();
    this.items.push(itemoptions);
    this.height=this.lh*this.items.length+2*this.border;
  },

  //Remove item from Menu
  //By index or by title. Revmove the first founded when there is many same title;
  removeItem:function(i){
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
    this.height=this.lh*this.items.length+2*this.border;
  },

  load:function(x,y,binder){
    setTimeout(function(){
      //Create a Element , if it is not exist
      var m;
      this.binder=binder;
      if(this.el){
        this.log("load menu cache");
        m=this.el;
      }else{
        this.log("create menu element");

        m = Builder.node("ul", {
          id:Math.random(),
          "class": "p_h_m",
          "style":"width:"+this.width+"px; border-width:"+this.border+"px"
        });

        this.items.each(function(i){
          var pdleft=10;
          var stylestr="";
          if(i.imgurl){
            stylestr+=" background-image:url("+i.imgurl+"); background-repeat:no-repeat; background-position:"+pdleft+"px center;";
            pdleft=16+pdleft;
          }
          var menuitem=Builder.node("li",{
            "class":i.handler?"has_event":"no_event",
            "style":"padding-left:"+pdleft+"px; width:"+(this.width-pdleft)+"px;"+stylestr
          },i.title);

          i.el = menuitem;

          //bind event
          var f=i.handler||function(){};

          Event.observe(menuitem,"mouseover",function(evt){
            evt.stop();
            Element.addClassName(menuitem,"item-mouseover");
          }.bindAsEventListener(this));

          Event.observe(menuitem,"mouseout",function(evt){
            Element.removeClassName(menuitem,"item-mouseover");
          }.bindAsEventListener(this));

          Event.observe(menuitem,"mousedown",function(evt){
            evt.stop();
          })

          Event.observe(menuitem,"click",function(evt){
            evt.stop();
            Element.removeClassName(menuitem,"item-mouseover");
            f.bind(this.binder)();
            this.unload();
          }.bindAsEventListener(this));

          Event.observe(menuitem,"contextmenu",function(evt){
            evt.stop();
          }.bindAsEventListener(this))

          $(m).insert(menuitem);

        }.bind(this));

        document.observe("click",function(evt){
          this.unload();
        }.bindAsEventListener(this));

        this.el=m;
      }

      this.items.each(function(i){
        if(i.flag && !i.flag()){
          $(i.el).hide(); //2008-12-25 加入一个判断某菜单项是否显示的标志
        }else{
          $(i.el).show();
        }
      }.bind(this));

      //append to body
      this.el.style.left=x+"px";
      this.el.style.top=y+"px";
      this.observer.appendChild(this.el);
      this.afterload();
      this.isload=true;
    }.bind(this),0)
  },

  _getPosition:function(evt,sayer,at){
    var x;
    var y;

    //2008.6.15 fix
    var oof=Element.cumulativeOffset(this.observer.parentNode);
    var ox=oof.left;
    var oy=oof.top;

    switch(at){
      case "bottom":
      case "bottom_left":{
          var p=sayer.cumulativeOffset();
          var s=sayer.getDimensions();
          x=p[0]-ox;
          y=p[1]+s.height-oy;
          break;
        }
      case "bottom_center":{
        var p=sayer.cumulativeOffset();
        var s=sayer.getDimensions();
        x=p[0]+(s.width-this.width)/2-ox;
        y=p[1]+s.height-oy;
        break;
      }
      case "bottom_right":{
        var p=sayer.cumulativeOffset();
        var s=sayer.getDimensions();
        x=p[0]+s.width-this.width-2*this.border-ox;
        y=p[1]+s.height-oy;
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
    if (this.isload) {
      this.el.remove();
      this.isload=false;
    }
  }
}
//---Menu code end