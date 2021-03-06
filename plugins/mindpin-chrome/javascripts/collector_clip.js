/*
 * 页面元素选择
 */
chrome.extension.onRequest.addListener(
  function(request, sender, sendResponse) {
    if (request.operate_clip == "begin"){
      CollectorClip.begin_clip(document);
    }else if(request.operate_clip == "cancel"){
      CollectorClip.cancel_clip();
    }else if(request.operate_clip == "send_elements"){
      sendResponse({
        final_data : CollectorClip.cliped_elements()
      })
    }
  }
  );

    

var CollectorClip = {

  init: function(document){
    this.document = document;
    this.location = this.document.location;
    this.coverlayer_top = $(this._make_coverlayer_dom());
    this.coverlayer_bottom = $(this._make_coverlayer_dom());
    this.coverlayer_left = $(this._make_coverlayer_dom());
    this.coverlayer_right = $(this._make_coverlayer_dom());
  },

  // 开始选择
  begin_clip : function(document){
    this.init(document);
    this.start_clip();
  },

  // 销毁所有的选择框
  remove_coverlayer : function(){
    this.coverlayer_top = null;
    this.coverlayer_bottom = null;
    this.coverlayer_left = null;
    this.coverlayer_right = null;
  },

  // 隐藏选择框
  hide_coverlayer : function(){
    this.coverlayer_top.hide();
    this.coverlayer_bottom.hide();
    this.coverlayer_left.hide();
    this.coverlayer_right.hide();
  },

  // 显示选择框
  show_coverlayer : function(){
    this.coverlayer_top.show();
    this.coverlayer_bottom.show();
    this.coverlayer_left.show();
    this.coverlayer_right.show();
  },

  // 取消选择
  cancel_clip : function(){
    if(typeof(this.document)!="undefined"&&this.document){
      this.remove_clip_cover();
      this.remove_coverlayer();
      this.cancel_cliped_elements();
      $(this.document.body).unbind();
    }
  },

  // 删除所有的选择框
  remove_clip_cover : function(){
    $(this.document.body).find('.mindpin_clip_coverlayer').each(function(index,m){
      $(m).remove();
    });
  },

  // 把已经选的元素全部取消掉
  cancel_cliped_elements : function(){
    $(".choosed_element",this.document).each(function(i,m){
      try{
        $(m).remove()
      }catch(e){}
    })
  },

  // 创建选择按钮 框 的dom
  _make_coverlayer_dom:function(){
    var coverlayer_dom = this.document.createElement("div");
    coverlayer_dom.setAttribute("class","mindpin_clip_coverlayer");
    coverlayer_dom.setAttribute("style","background-color:#FF0000;position:absolute;opacity:1;");
    return $(coverlayer_dom).hide();
  },

  // 开始选择
  start_clip: function(){
    var body = $(this.document.body);
    if(body.hasClass('MINDPIN_COLLECTOR_CLIP')){
      body.attr('class','MINDPIN_COLLECTOR_CLIP');
    }
    body.bind('mouseover',function(evt){
      CollectorClip._select_clip(evt);
    });
    body.bind('click',function(evt){
      CollectorClip._do_clip(evt);
    });
    body.bind('mouseout',function(){
      CollectorClip.hide_coverlayer();
    });
  },

  send_sign_to_button : function(sign){
    chrome.extension.sendRequest({
      send_clip_elements:sign
    },function(){})
  },

  // 检测 元素 是否 可以被选择
  can_be_clip:function(el){
    var body = CollectorClip.document.body;
    var c1 = (!el.hasClass('mindpin_clip_coverlayer'));
    var c2 = (el != body);
    var c3 = (el[0].parentNode != body || el[0].tagName!='DIV');
    var c4 = CollectorClip.clip_big_block(el);
    var c5 = (!el.hasClass('choosed_element'));
    var c6 = CollectorClip.check_tag_name(el);
    return c1 && c2 && c3 && c4 && c5 && c6;
  },

  // 统计选择的 块数 以及 字符数， 并反映到 发送捕捉元素 这个按钮上
  statis_clip_elements : function(){
    var cliped_elements = $(this.document).find('.choosed_element');
    var number = cliped_elements.length;
    var char_number = 0;
    $(cliped_elements).each(function(i,el){
      char_number += ($(el).text().length);
    })
    chrome.extension.sendRequest({
      div_number:number,
      char_number:char_number
    },function(){})
  },

  // 大块元素 只有 在小于一定值的时候才 视为可选状态
  clip_big_block : function(el){
    if (el.attr("tagName") != 'IMG') {
      var width = el.outerWidth();
      var height = el.outerHeight();
      if ((width > 250 && height > 500) || (width > 500 && height > 250)) {
        return false;
      }
    }
    return true
  },

  // 检测标签的类型，如下标签一律不选,不再如下标签中，返回true（表示可以选择）
  check_tag_name : function(el){
    var black_list =["BODY", "HTML", "FRAME", "FRAMESET", "IFRAME", "A", "INPUT", "BUTTON", "EMBED"]
    return jQuery.inArray(el.attr("tagName"), black_list) == -1
  },

  // 选择开始
  _select_clip:function(evt){
    var el = $(evt.target);
    if(this.can_be_clip(el)){
      evt.stopPropagation();
      this.put_clip_doms(el);
    }else{
      $(this.document.body).find('.mindpin_clip_coverlayer').each(function(index,m){
        //console.log(m)
        $(m).remove();
      })
    }
  },

  //  显示选择框
  put_clip_doms:function(el){

    var d = {
      width:el.outerWidth(),
      height:el.outerHeight()
    };
    var o = el.offset();
    var b = 2;
    this.coverlayer_top.css({
      'width': d.width + 'px',
      'height': b + 'px',
      'top': o.top + 'px',
      'left': o.left + 'px'
    }).show();
    this.coverlayer_bottom.css({
      'width': d.width + 'px',
      'height': b + 'px',
      'top': o.top + d.height - b + 'px',
      'left': o.left + 'px '
    }).show();
    this.coverlayer_left.css({
      'width': b + 'px',
      'height': d.height + 'px',
      'top': o.top + 'px',
      'left': o.left + 'px'
    }).show();
    this.coverlayer_right.css({
      'width': b + 'px',
      'height': d.height + 'px',
      'top': o.top + 'px',
      'left': o.left + d.width - b + 'px'
    }).show();
    $(this.document.body).append(this.coverlayer_top);
    $(this.document.body).append(this.coverlayer_bottom);
    $(this.document.body).append(this.coverlayer_left);
    $(this.document.body).append(this.coverlayer_right);
  },

  // 点击选择框的范围
  _do_clip:function(evt){
    var el = $(evt.target);
    // 如果el不能被点击，则直接返回
    if(!this.can_be_clip(el)){
      return
    }
    var el_copy = el.clone().hide();
    // 选择框
    var choose_div = this.document.createElement("div");
    choose_div.setAttribute("style","background-color:#74DF00;position:absolute;opacity:0.9;")
    choose_div.setAttribute("class","choosed_element");
    $(choose_div).css({
      "width":el.outerWidth()+"px",
      "height":el.outerHeight()+"px",
      "top":el.offset().top+"px",
      "left":el.offset().left+"px"
    })
    // 取消选择的按钮
    var close_link = this.document.createElement("a");
    $(close_link).bind("click",$.proxy(function(){
      var parent = $(close_link).parent(".choosed_element")
      parent.remove();
      CollectorClip.statis_clip_elements();
    }),this)
    //    $(close_link).attr("innerHTML","取消");
    $(close_link).attr("class","cancel_link_for_page_clip");
    $(close_link).attr("style","background:url(http://ui.mindpin.com/images/piece/highlight-close.png) no-repeat 0px 0px;height:16px;width:16px;display:block;opacity:1;float:right;cursor:hand;");
    choose_div.appendChild(close_link);
    var data_div = this.document.createElement("div");
    data_div.setAttribute("class","data_element");
    data_div.appendChild(el_copy[0]);
    // 把选中元素的clone放进选择框，并隐藏掉，便于去取
    choose_div.appendChild(data_div);
    this.document.body.appendChild(choose_div);
    CollectorClip.statis_clip_elements();
    evt.preventDefault();
  },

  cliped_elements : function(){
    var link_result = [];
    var link_datas = $(".choosed_element .data_element a[class!='cancel_link_for_page_clip']",this.document)
    link_datas.each(function(i,m){
      var href_str = ToolLib.check_url($(m).attr("href"),CollectorClip.location)
      link_result[i] = {
        href:href_str,
        text:$(m).attr("innerHTML")
      };
    })

    var image_result = [];
    var image_datas = $(".choosed_element .data_element img",this.document)
    image_datas.each(function(i,m){
      var image_src = ToolLib.check_url($(m).attr("src"),CollectorClip.location)
      image_result[i] = {
        src:image_src,
        width:$(m).attr("width"),
        height:$(m).attr("height")
      };
    })
    
    return {
      rsses:[],
      images:image_result,
      links:link_result
    };
  }

}