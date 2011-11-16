/** pielib Core version 0.2
 *  (c) 2006-2008 MindPin.com - songliang
 *  
 *  created at 2007.03.27
 *  updated on 2008.6.13 
 *  
 *  require:
 *  prototype.js ver 1.6.0.1
 *  
 *  working on //W3C//DTD XHTML 1.0 Strict//EN"
 *
 *  For details, to the web site: http://www.mindpin.com/
 *--------------------------------------------------------------------------*/

pie={
	html:{},
	dom:{},
	data:{},
	js:{},
	util:{}
};

//bug fix..

//ie 6 image cache
//修正ie6的小图片反复加载问题
try{
	document.execCommand('BackgroundImageCache', false, true);
}catch(e){}

pie.isIE=function(){
	return window.navigator.userAgent.indexOf("MSIE")>=1;
}

pie.isFF=function(){
	return window.navigator.userAgent.indexOf("Firefox")>=1;
}

pie.isChrome=function(){
	return window.navigator.userAgent.indexOf("Chrome")>=1;
}

pie.randstr=function(length){
  length = length || 8;
  var base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".toArray();
  var size = base.length;
  var j = pie.rand(size-10);
  re = base[j]
  for(var i=1;i<length;i++){
    j = pie.rand(size)
    re = re + base[j]
  }
  return re;
}

pie.rand=function(num){
  var i = Math.random()
  return Math.round(i*(num-1))
}

Element.addMethods({
  makeUnselectable: function(element, cursor){
    cursor = cursor || 'default';
    element.onselectstart = function(){
      return false;
    };
    element.unselectable = "on";
    element.style.MozUserSelect = "none";
    return element;
  },
  makeSelectable: function(element){
    element.onselectstart = function(){
      return true;
    };
    element.unselectable = "off";
    element.style.MozUserSelect = "";
    return element;
  },
  do_click:function(element){
    pie.do_click(element)
  }
});

// 对Date的扩展，将 Date 转化为指定格式的String
// 月(M)、日(d)、小时(h)、分(m)、秒(s)、季度(q) 可以用 1-2 个占位符，
// 年(y)可以用 1-4 个占位符，毫秒(S)只能用 1 个占位符(是 1-3 位的数字)
// 例子：
// (new Date()).getFormatValue("yyyy-MM-dd hh:mm:ss.S") ==> 2006-07-02 08:09:04.423
// (new Date()).getFormatValue("yyyy-M-d h:m:s.S")      ==> 2006-7-2 8:9:4.18
Date.prototype.getFormatValue = function(fmt){
  //author: meizz
  var o = {
    "M+" : this.getMonth()+1,                 //月份
    "d+" : this.getDate(),                    //日
    "h+" : this.getHours(),                   //小时
    "m+" : this.getMinutes(),                 //分
    "s+" : this.getSeconds(),                 //秒
    "q+" : Math.floor((this.getMonth()+3)/3), //季度
    "S"  : this.getMilliseconds()             //毫秒
  };
  if(/(y+)/.test(fmt))
    fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length));
  for(var k in o)
    if(new RegExp("("+ k +")").test(fmt))
  fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
  return fmt;
}


pie.do_click = function(id,evt){
  var fire_on_this = $(id)
  if (document.createEvent){
    var evObj = document.createEvent('MouseEvents')
    evObj.initEvent( 'click', true, false )
    fire_on_this.dispatchEvent(evObj)
  }
  else if (document.createEventObject){
    fire_on_this.fireEvent('onclick')
  }
  if(evt) evt.stop();
}

pie.charslength = function (str){
  var i,sum;
  sum = 0;
  for(i=0;i<str.length;i++){
    var c = str.charCodeAt(i);
    sum += ((c>=0) && (c<=255)) ? 1:2;
  }
  return sum;
}

pie.truncate_u = function(str,length){
  var i,sum;
  sum = 0;
  res = ''
  for(i=0;i<str.length;i++){
    var c = str.charCodeAt(i);
    var ch = str[i];
    var is_hanzi = (c>=0) && (c<=255);
    if(sum < length) res += ch+'';
    sum += is_hanzi ? 1:2;
  }
  if(res.length < str.length) res+='...'
  return res;
}

//effects
pie.highlight=function(elm){
  var jq_elm = jQuery(elm);
  
  jq_elm.css('background-color','#FFFADA');
  jq_elm.animate({
    backgroundColor:'white'
  },500,function(){
    jq_elm.css('background-color','');
  })
}

pie.replace_dom=function(new_elm, old_elm){
  jQuery(new_elm).hide().fadeIn(200);
  jQuery(old_elm).before(new_elm);
  jQuery(old_elm).remove();
}

//---XML code begin
pie.dom.xml={
  //获取空的XML解析对象
  getXMLDoc:function(){
    var xmlDoc=null;
    if(document.implementation && document.implementation.createDocument){
      xmlDoc=document.implementation.createDocument("","",null);
    }else if(typeof ActiveXObject != "undefined"){
      xmlDoc=new ActiveXObject('MSXML2.DOMDocument');
    }
    xmlDoc.async = false;
    return xmlDoc;
  },
  //从字符串获取XML解析对象
  getXMLDocFromString:function(str){
    var xmlDoc=null;
    if(document.implementation && document.implementation.createDocument){
      var parser=new DOMParser();
      xmlDoc = parser.parseFromString(str, "text/xml");
      delete parser;
    }else if(typeof ActiveXObject != "undefined"){
      xmlDoc=new ActiveXObject('MSXML2.DOMDocument');
      xmlDoc.loadXML(str);
    }
    return xmlDoc;
  },
  //进行XSLT->XML转换,返回字符串
  transformXML:function(xmlDoc,xslDoc){
    if(window.ActiveXObject){
      return xmlDoc.documentElement.transformNode(xslDoc);
    }else{
      var xsltProcessor = new XSLTProcessor();
      xsltProcessor.importStylesheet(xslDoc);
      var fragment = xsltProcessor.transformToFragment(xmlDoc,document);
      var e=document.createElement("div");
      e.appendChild(fragment);
      return e.innerHTML;
    }
  },
  //将xml对象转化为字符串的方法
  serialize:function(dom) {
    var xml = dom.xml;
    if (xml == undefined) {
      try{
        var serializer = new XMLSerializer();
        xml = serializer.serializeToString(dom);
        delete serializer;
      } catch (error) {
        if (debug)
          alert("DOM serialization is not supported.");
      }
    }
    return xml;
  }
}
//---XML code end

//firefox控制台方法代理
pie.log = function(){
  var arr = [];
  for(i=0;i<arguments.length;i++){
    arr.push('arguments['+i+']')
  }
  eval('try{console.log('+arr.join(',')+')}catch(e){}')
}

pie.dir = function(){
  var arr = [];
  for(i=0;i<arguments.length;i++){
    arr.push('arguments['+i+']')
  }
  eval('try{console.dir('+arr.join(',')+')}catch(e){}')
}

pie.open_win = function(url,w,h,wname){
  var width = w||520;
  var height = h||420;
  var win_name = wname || "connect_window"

  var left = (document.body.clientWidth - width) / 2;
  var top = (document.body.clientHeight - height) / 2;

  window.open(url, win_name, "height="+height+", width="+width+", toolbar =no, menubar=no, scrollbars=yes, resizable=no,top=" + top + ",left=" + left + ", location=no, status=no");
}

//onload
pie.load = function(func){
  jQuery(document).ready(function(){
    try{func();}catch(e){alert(e.name + ':' + e.message);}
  });
}

//---以下是方法重载--------
if (pie.isFF()){
  HTMLElement.prototype.contains=function(node){// 是否包含某节点
    do if(node==this)return true;
    while(node=node.parentNode);
    return false;
  }
	
  HTMLElement.prototype.__defineGetter__("outerHTML",function(){
    var attr;
    var attrs=this.attributes;
    var str="<"+this.tagName;
    for(var i=0;i<attrs.length;i++){
      attr=attrs[i];
      if(attr.specified)
        str+=" "+attr.name+'="'+attr.value+'"';
    }
    if(!this.canHaveChildren)
      return str+">";
    return str+">"+this.innerHTML+"</"+this.tagName+">";
  });

  HTMLElement.prototype.__defineGetter__("canHaveChildren",function(){
    return !/^(area|base|basefont|col|frame|hr|img|br|input|isindex|link|meta|param)$/.test(this.tagName.toLowerCase());
  });
	
  Event.prototype.__defineGetter__("fromElement",function(){// 返回鼠标移出的源节点
    var node;
    if(this.type=="mouseover")
      node=this.relatedTarget;
    else if(this.type=="mouseout")
      node=this.target;
    if(!node) return null;
    while(node.nodeType!=1)node=node.parentNode;
    return node;
  });
	
  Event.prototype.__defineGetter__("toElement",function(){// 返回鼠标移入的源节点
    try{
      var node;
      if(this.type=="mouseout")
        node=this.relatedTarget;
      else if(this.type=="mouseover")
        node=this.target;
      if(!node || (node.tagName=='INPUT' && node.type=='file')) return null;
      while(node.nodeType!=1) node=node.parentNode;
      return node;
    }catch(e){}
  });
}

//--pin_url_for
MINDPIN_URLS = {
  "production" : {
    "user_auth"               :  "http://www.mindpin.com/",
    "pin-user-auth"           :  "http://www.mindpin.com/",
    "discuss"                 :  "http://discuss.mindpin.com/",
    "pin-discuss"             :  "http://discuss.mindpin.com/",
    "pin-workspace"           :  "http://workspace.mindpin.com/",
    "ui"                      :  "http://ui.mindpin.com/",
    "pin-bugs"                :  "http://bugs.mindpin.com/",
    "pin-app-adapter"         :  "http://app-adapter.mindpin.com/",
    "pin-share"               :  "http://share.mindpin.com/",
    "pin-mindmap-editor"      :  "http://mindmap-editor.mindpin.com/",
    "pin-mindmap-image-cache" :  "http://mindmap-image-cache.mindpin.com/",
    "pin-macro"               :  "http://macro.mindpin.com/",
    "pin-website"             :  "http://website.mindpin.com/",
    "pin-notes"               :  "http://notes.mindpin.com/",
    "pin-mev6"                :  "http://mev6.mindpin.com/"
  },
  "development":{
    "user_auth"               :  "http://dev.www.mindpin.com/",
    "pin-user-auth"           :  "http://dev.www.mindpin.com/",
    "discuss"                 :  "http://dev.discuss.mindpin.com/",
    "pin-discuss"             :  "http://dev.discuss.mindpin.com/",
    "pin-workspace"           :  "http://dev.workspace.mindpin.com/",
    "ui"                      :  "http://dev.ui.mindpin.com/",
    "pin-bugs"                :  "http://dev.bugs.mindpin.com/",
    "pin-app-adapter"         :  "http://dev.app-adapter.mindpin.com/",
    "pin-share"               :  "http://dev.share.mindpin.com/",
    "pin-mindmap-editor"      :  "http://dev.mindmap-editor.mindpin.com/",
    "pin-mindmap-image-cache" :  "http://dev.mindmap-image-cache.mindpin.com/",
    "pin-macro"               :  "http://dev.macro.mindpin.com/",
    "pin-website"             :  "http://dev.website.mindpin.com/",
    "pin-notes"               :  "http://dev.notes.mindpin.com/",
    "pin-mev6"                :  "http://dev.mev6.mindpin.com/"
  }
}

pie.pin_url_for = function(site,path){
  var site_url = MINDPIN_URLS[pie.env][site];
  path = path || ''
  if(path.blank()){
    return site_url;
  }
  return site_url + path.gsub(/^\//,'');
}