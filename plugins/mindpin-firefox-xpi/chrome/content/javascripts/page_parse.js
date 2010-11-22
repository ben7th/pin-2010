/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
}
Mindpin.PageParse = {
  init : function(){
    getSidebarWindow().$("#package_send_button").attr("disabled","true");
    Mindpin.PageParse.parse_html();
  },
  
  parse_html : function(){
    var html_document = getWebWindow().document.getElementsByTagName("html")[0];
    Mindpin.PageParse.parse_and_send_links(html_document);
    Mindpin.PageParse.parse_and_send_images(html_document);
    Mindpin.PageParse.parse_and_send_rss(html_document);
  },

  // 解析rss资源
  parse_and_send_rss : function(html_document){
    var rss_boxs = getSidebarWindow().$("#current_page_info_rss")[0];
    Mindpin.PageParse.remove_children(rss_boxs);
    $("[type='application/rss+xml']",html_document).each(function(index){
      var rss_box = getSidebarWindow().document.createElement("hbox");
      rss_box.setAttribute("align","start");
      rss_box.setAttribute("class","rss-box");

      var checkbox = Mindpin.PageParse.add_checkbox();
      rss_box.appendChild(checkbox);
      
      var link = getSidebarWindow().document.createElement("label");
      var link_str = Mindpin.PageParse.check_url($(this).attr("href"));
      link.setAttribute("value","rss源  --  "+ $(this).attr("title"));
      link.href_str = link_str;
      link.setAttribute("class","text-link rss-data");
      link.addEventListener("click",function(){
        var gbrowser = getFireFoxWindow().gBrowser;
        gbrowser.selectedTab = gbrowser.addTab(link_str);
      },false);
      rss_box.appendChild(link);
//      Mindpin.PageParse.add_share_link(rss_box,link_str)

      rss_boxs.appendChild(rss_box)
    });
  },

  // 解析并输出所有的链接资源
  parse_and_send_links : function(html_document){
    var link_boxs = getSidebarWindow().$("#current_page_info_links")[0];
    Mindpin.PageParse.remove_children(link_boxs);
    var location = getWebWindow().location;
    var side_win = getSidebarWindow();
    $("a",html_document).each(function(index){
      
      
      var href = $(this).attr("href");
      href = Mindpin.PageParse.check_url(href);
      if(Mindpin.PageParse.is_ignorable_url(href,location)){return}
      
      var link_box = side_win.document.createElement("hbox");
      link_box.setAttribute("align","start")
      link_box.setAttribute("class","link-box")
      // checkbox
      link_box.appendChild(Mindpin.PageParse.add_checkbox());
      // 如果是外链给出提示
      if(!Mindpin.PageParse.url_is_current_site(href,location)){
        var tip = side_win.document.createElement("label");
        tip.setAttribute("value","外链")
        link_box.appendChild(tip);
      }
      // 链接地址
      var link = side_win.document.createElement("label");
      link.setAttribute("value",$(this).text());
      link.href_str = href
      link.setAttribute("class","text-link link-data");
      link.addEventListener("click",function(){
        var gbrowser = getFireFoxWindow().gBrowser;
        gbrowser.selectedTab = gbrowser.addTab(href);
        return false;
      },false);
      link_box.appendChild(link);
      // 分享按钮
//      Mindpin.PageParse.add_share_link(link_box,href);

      link_boxs.appendChild(link_box);
    });
  },

  // 解析输出图片资源
  parse_and_send_images : function(html_document){
    var box_images = getSidebarWindow().$("#current_page_info_images")[0];
    Mindpin.PageParse.remove_children(box_images);
    $("img",html_document).each(function(index){
      var a_image_box = Mindpin.PageParse.create_image_box_element($(this));
      box_images.appendChild(a_image_box);
    });
  },

  // 根据传进来的对象 创建一个图像标签(外围使用vbox包围，后面跟一个分享的链接)
  create_image_box_element : function(image_element){
    var document = getSidebarWindow().document;
    var new_src = Mindpin.PageParse.check_url(image_element.attr("src"));
    $(image_element).attr('src',new_src);
    var image = Mindpin.PageParse.add_image_element(document,image_element);
    image.setAttribute("class","image-data");
//    var share_image_link = Mindpin.PageParse.add_share_image_link_element(document,image_element);
    var a_image_box = document.createElement("vbox");
    a_image_box.setAttribute("align","start");
    a_image_box.setAttribute("class","image-box");
    a_image_box.appendChild(image)
    var checkbox = Mindpin.PageParse.add_checkbox();
    a_image_box.appendChild(checkbox);
//    a_image_box.appendChild(share_image_link)
//    a_image_box.addEventListener("mouseover",function(){
//      Mindpin.PageParse.show_share_button_for_image_box(a_image_box);
//    },false);
//    a_image_box.addEventListener("mouseout",function(){
//      Mindpin.PageParse.hide_share_button_for_image_box(a_image_box);
//    },false);
    return a_image_box;
  },

  // box中添加分享按钮
  add_share_image_link_element: function(document,image_element){
    var share_link = document.createElement("label");
    share_link = Mindpin.PageParse.init_share_link(share_link);
    share_link.addEventListener("click",function(){
      Mindpin.PageParse.show_image_window({
        'image_src':image_element.attr('src'),
        "width":image_element.attr('width'),
        "height":image_element.attr('height')
      });
    },false);
    return share_link;
  },
  
  init_share_link : function(share_link){
    share_link.setAttribute("value","分享");
    share_link.setAttribute("class","text-link");
    share_link.setAttribute("style","visibility:hidden;");
    return share_link;
  },

  // box中添加image元素
  add_image_element : function(document,image_element){
    var image = document.createElement("image");
    var image_src = Mindpin.PageParse.check_url(image_element.attr("src"));
    var width = image_element.attr("width");
    var height = image_element.attr("height");
    image.setAttribute("src",image_src);
    image = Mindpin.PageParse.set_image_size(image,width,height)
    image.addEventListener("click",function(){
      Mindpin.PageParse.show_image_window({
        'image_src':image_src,
        "width":width,
        "height":height
      });
    },false);
    return image;
  },

  // 处理图片大小
  // 设置图片高度100 宽度最大130
  set_image_size : function(image,width,height){
    var new_height = height;
    var new_width = width;
    var skeil = width/height ;
    if(new_height > 100){
      new_height = 100;
      new_width = skeil*100;
    }
    if(new_width > 130){
      new_width = 130;
      new_height = (1/skeil)*130;
    }
    image.setAttribute("height",new_height);
    image.setAttribute("width",new_width);
    image.setAttribute("style","margin:0px 0px 0px 5px;");
    return image;
  },

  show_image_window : function(options){
    Mindpin.CollectionImageWindow.show(options);
  },

  show_share_button_for_image_box : function(a_image_box){
    a_image_box.getElementsByClassName("text-link")[0].setAttribute("style","visibility:visible;");
  },

  hide_share_button_for_image_box : function(a_image_box){
    a_image_box.getElementsByClassName("text-link")[0].setAttribute("style","visibility:hidden;");
  },
  
  // 检查url，对那些不完整的url进行修复
  check_url : function(url){
    if(Mindpin.PageParse.is_ignorable_url(url)){return url}
    var location = getWebWindow().location;
    var host = location.host;
    var protocol = location.protocol;
    var site = protocol + "//" + host;
    
    if(/^http/.test(url)){
      return url;
    }else{
      if(/^\//.test(url)){
        return site + url
      }
      return site + "/" + url;
    }
  },

  // 判断 URL 是否是当前 site 的 地址
  url_is_current_site: function(url,location){
    var current_site = location.protocol + "//" + location.host;
    if(new RegExp(current_site).test(url)){
      return true;
    }
    return false;
  },

  // 是否是可忽略的 地址
  is_ignorable_url: function(url){
    if(/^(javascript:|#)/.test(url)){
      return true;
    }
    return false;
  },

  // vbox每次都进行初始化
  remove_children : function(box){
    while (box.firstChild){
      box.removeChild(box.firstChild);
    }
  },

  // 增加share按钮
  add_share_link : function(box,data){
    var share_link = getSidebarWindow().document.createElement("label");
    share_link.setAttribute("value","分享");
    share_link.setAttribute("class","text-link");
    share_link.addEventListener("click",function(){
      Mindpin.CollectionTextWindow.share_ui(data);
    },false);
    box.appendChild(share_link);
  },

  // 增加复选框
  add_checkbox : function(){
    var checkbox = getSidebarWindow().document.createElement("checkbox");
    checkbox.setAttribute("class","package_checkbox");
    checkbox.addEventListener("command",function(){
      // 当多有的复选框中，只要有一个没有选中，打包发送这个按钮就要显示为不可用
      // 只要有一个可点，打包发送这个按钮就可用
      if(checkbox.checked){
        getSidebarWindow().$("#package_send_button").attr("disabled","false");
      }else{
        var size = getSidebarWindow().$(".package_checkbox[checked='true']").length
        if(size==0){
          getSidebarWindow().$("#package_send_button").attr("disabled","true");
        }else{
          getSidebarWindow().$("#package_send_button").attr("disabled","false");
        }
      }
    },false);
    return checkbox;
  },

  // 打开我的导图列表
  open_mindmap_list_page:function(){
    window.close();
    var gbrowser = getFireFoxWindow().gBrowser;
    var tab = gbrowser.addTab(Mindpin.MINDMAP_LIST_URL);
    gbrowser.selectedTab = tab;
  },

  // 提示正在生成导图
  produce_mindmap_ui: function(){
    var html = getWebWindow().document.getElementsByTagName("html")[0].innerHTML;
    html = "<html>" + html + "</html>"
    window.openDialog("chrome://mindpin/content/produce_mindmap.xul", "ProduceMindmap", "chrome,dialog,centerscreen,modal,resizable=no",html);
  },

  package_send : function(){
    // 查找选中的rss
    var rsses_array = []
    $("hbox.rss-box .package_checkbox[checked='true']").each(function(index){
      var rss_data = $(this).siblings('.rss-data')[0];
      rsses_array[index] = {href:rss_data.href_str,text:rss_data.value};
    });

    //查找所有选中的links
    var links_array = []
    $("hbox.link-box .package_checkbox[checked='true']").each(function(index){
      var link_data = $(this).siblings('.link-data')[0];
      links_array[index] = {href:link_data.href_str,text:link_data.value};
    });

    //查找所有选中的images
    var images_array = []
    $("vbox.image-box .package_checkbox[checked='true']").each(function(index){
      var image_data = $(this).siblings('.image-data')[0];
      images_array[index] = {src:image_data.src,width:image_data.width,height:image_data.height};
    });
    var final_data = {rsses:rsses_array,images:images_array,links:links_array};
    window.openDialog("chrome://mindpin/content/package_send_window.xul", "collection_text_window", "chrome,dialog,centerscreen,modal,resizable=no",final_data);
  },

  // 生成导图
  produce_mindmap: function(){
    var success = function(responseText){
      var tip = "生成导图成功，您可以点击下边链接查看"
      $("#tip").attr("value",tip)
      $("#mindmap_list_url").attr("value",Mindpin.MINDMAP_LIST_URL)
      $("#mindmap_list_url").attr("hidden","false")
      $("#close_button").attr("hidden","false")
    }
    var auth = function(xhr,status,error_throw){
      alert("未知错误")
      $("#tip").attr("value",xhr.responseText)
      $("#close_button").attr("hidden","false")
    }
    $.ajax({
      url: Mindpin.PRODUCE_MINDMAP_URL,
      type: "post",
      async: true,
      data: {
        html:window.arguments[0]
      },
      dataType: "text",
      success: success,
      error: auth
    });
  }
}