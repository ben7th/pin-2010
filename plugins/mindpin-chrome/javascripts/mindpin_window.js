var BG = chrome.extension.getBackgroundPage();
BG.MindpinWin.window = window;
MindpinWindow = {
  init: function(){
    // 注册一些事件
    this.add_events();
    this.loading_ui();
    this.show();
  },

  add_events: function(){
    // 退出登录按钮
    $("#logout").click(function(evt){
      BG.Mindpin.UserManager.logout();
      evt.preventDefault();
    });

    // 登录按钮
    $("#login").click(function(evt){
      BG.Mindpin.UserManager.prompt_user_login();
      evt.preventDefault();
    });
    // 注册按钮
    $("#register").click(function(evt){
      window.open(BG.Mindpin.REGISTER_URL)
      evt.preventDefault();
    });
    // 打包发送按钮
    $("#package_send").click(function(evt){
      evt.preventDefault();
      MindpinWindow.pack_send_elements()
    });
  },

  loading_ui: function(){
    
  },
  show: function(){
    var user = BG.Mindpin.UserManager.get_user();
    if(user){
      this.logined_ui(user);
    }else{
      this.unlogin_ui();
    }
  },
  logined_ui: function(user){
    $("#user_name").text(user.name);
    $("#user_avatar_img").attr("src",user.avatar);
    $("#unlogin_action").hide();
    $("#logined_action").show();
    this.show_window_content();
  },
  unlogin_ui: function(){
    $("#logined_action").hide();
    $("#unlogin_action").show();
    this.hide_window_content();
  },
  
  check_open_and_show: function(){
    this.loading_ui();
    this.show();
  },
  
  // 隐藏窗体内容
  hide_window_content : function(){
    $("#mindpin_window_content").hide();
  },
  
  // 显示窗体内容
  show_window_content : function(){
    $("#mindpin_window_content").show();
    this.show_page_info_comments();
    this.show_browse_history();
    this.show_page_content();
  },
  
  // 显示网页信息 以及网页评注
  show_page_info_comments : function(){
    if(BG.CurrentCorrectTab.url!=""){
      this.show_url_content(BG.CurrentCorrectTab.url);
    }
  },
  
  show_url_content : function(url){
    $.ajax({
      url:BG.Mindpin.WEB_SITE_INFOS_URL,
      data:{
        url:url
      },
      success:function(data){
        $("#web_site_info").html($("#web_site_info_template").tmpl(data))
      }
    });
  },
  
  // 显示历史记录
  show_browse_history : function(){
    $("#mindpin_window_content #browse_history_iframe").attr("src",BG.Mindpin.BROWSE_HISTORIES_URL);
  },

  // 显示解析到的页面元素
  show_page_content : function(){
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      give_content: "ok"
    }, function(response) {
      // 在第三个页签中插入元素
      $("#rsses_content").attr("innerHTML","");
      $("#links_content").attr("innerHTML","");
      $("#images_content").attr("innerHTML","");
      
      $(response.page_content.rsses).each(function(i,link){
        $("#rsses_content").append("<div class='rss_item'><input class='package_checkbox' type='checkbox'><a class='data' href="+link.href+">"+link.text+"</a> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });
      $(response.page_content.links).each(function(i,link){
        $("#links_content").append("<div class='link_item'><input class='package_checkbox' type='checkbox'><a class='data' href="+link.href+">"+link.text+"</a> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });
      $(response.page_content.images).each(function(i,image){
        $("#images_content").append("<div class='image_item'><input class='package_checkbox' type='checkbox'><img class='data' src='"+image.src+"' width="+image.width+"px height="+image.height+"px /> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });

      // 注册 发送 分享 事件
      $("a.share").each(function(i,item){
        $(item).bind("click",function(){
          MindpinWindow.send_item("share",item)
        })
      });

      $("a.send").each(function(i,item){
        $(item).bind("click",function(){
          MindpinWindow.send_item("send",item)
        })
      });
      
    });
  },


  send_item : function(operate_type,item){
    var link = $(item).siblings('a.data')[0];
    var image = $(item).siblings('img.data')[0];
    if(image!=null){
      var image_data = {
        type:operate_type,
        data_type:"image",
        data:{
          src:image.src,
          width:image.width,
          height:image.height
        }
      }
      MindpinWindow.open_collection_window(image_data)
    }else{
      var link_data = {
        type:operate_type,
        data_type:"link",
        data:{
          href:link.href,
          text:$(link).text()
        }
      }
      MindpinWindow.open_collection_window(link_data)
    }
  },

  
  // 发送历史记录
  send_browse_history : function(url,title){
    $.ajax({
      url: BG.Mindpin.SUBMIT_BROWSE_HISTORIES_URL,
      type: "post",
      async: true,
      data: {
        'url':url,
        'title':title
      },
      dataType: "text",
      success: function(){
        MindpinWindow.show_browse_history();
      }
    });
  },

  open_collection_window : function(data){
    // 新打开的 发送文本页面 会取 collection_data 这个数据
    BG.collection_data = data
    if(data.data_type == "link"){
      window.open("collection_text_window.html", "CollectionTextWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
    }else if(data.data_type == "image"){
      window.open("collection_image_window.html", "CollectionImageWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
    }
  },
  
  // 选中元素的处理
  pack_send_elements : function(){
    var rsses = []
    $(".rss_item input.package_checkbox:checked").each(function(i,item){
      var link = $(item).siblings('a.data')[0];
      rsses[i] = {
        href:link.href,
        text:link.text
      }
    });
    var links = []
    $(".link_item input.package_checkbox:checked").each(function(i,item){
      var link = $(item).siblings('a.data')[0];
      links[i] = {
        href:link.href,
        text:link.text
      }
    });
    var images = []
    $(".image_item input.package_checkbox:checked").each(function(i,item){
      var image = $(item).siblings('img.data')[0];
      images[i] = {
        src:image.src,
        width:image.width,
        height:image.height
      }
    });
    var final_data = {
      rsses:rsses,
      links:links,
      images:images
    }
    // 新打开 的 打包发送页面会用到这个数据
    BG.package_send_data = final_data;
    window.open("package_send_window.html", "PackageSendWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
  },

  begin_clip : function(){
    $("#begin_clip").hide();
    $("#cancel_clip").show();
    $("#package_send_clip").show();
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      operate_clip: "begin"
    }, function(response) {
        
      });
  },

  cancel_clip : function(){
    $("#begin_clip").show();
    $("#cancel_clip").hide();
    $("#package_send_clip").hide();
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      operate_clip: "cancel"
    }, function(response) {

      });
  },

  package_send_clip : function(){
    
  }

}



$(document).ready(function(){
  MindpinWindow.init();
});
