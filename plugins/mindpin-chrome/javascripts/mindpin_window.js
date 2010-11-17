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
  },
  
  // 显示网页信息 以及网页评注
  show_page_info_comments : function(){
    if(BG.CurrentCorrectTab.url!=""){
      this.show_url_content(BG.CurrentCorrectTab.url);
    }
  },
  
  show_url_content : function(url){
    $("#mindpin_window_content #web_site_info_iframe").attr("src",BG.Mindpin.WEB_SITE_INFOS_URL+"?url="+encodeURIComponent(url));
    $("#mindpin_window_content #web_site_comments_iframe").attr("src",BG.Mindpin.WEB_SITE_COMMENTS_URL+"?url="+encodeURIComponent(url));
  },
  
  // 显示历史记录
  show_browse_history : function(){
    $("#mindpin_window_content #browse_history_iframe").attr("src",BG.Mindpin.BROWSE_HISTORIES_URL);
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
  }

}

$(document).ready(function(){
  MindpinWindow.init();
});
