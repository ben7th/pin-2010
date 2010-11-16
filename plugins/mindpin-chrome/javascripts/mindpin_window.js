var BG = chrome.extension.getBackgroundPage();
if(typeof(BG.Mindpin)=='undefined'){
  BG.Mindpin = {}
  }
var Mindpin = BG.Mindpin;

Mindpin.MindpinWindow = {
  init: function(){
    // 注册一些事件
    this.add_events();
    this.loading_ui();
    this.show();
  },

  add_events: function(){
    // 退出登录按钮
    $("#logout").click(function(evt){
      Mindpin.UserManager.logout();
      evt.preventDefault();
    });

    // 登录按钮
    $("#login").click(function(evt){
      Mindpin.UserManager.prompt_user_login();
      evt.preventDefault();
    });
    // 注册按钮
    $("#register").click(function(evt){
      window.open(Mindpin.REGISTER_URL)
      evt.preventDefault();
    });
  },
  
  loading_ui: function(){
    
  },
  show: function(){
    var user = Mindpin.UserManager.get_user();
    if(user){
      this.logined_ui(user);
    }else{
      this.unlogin_ui();
    }
  },
  logined_ui: function(user){
    $("#user_name").text(user.name)
    $("#unlogin_action",document).hide();
    $("#logined_action",document).show();
    this.show_window_content();
  },
  unlogin_ui: function(){
    $("#logined_action",document).hide();
    $("#unlogin_action",document).show();
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
    $("#mindpin_window_content #web_site_info_iframe").attr("src",Mindpin.WEB_SITE_INFOS_URL);
    $("#mindpin_window_content #web_site_comments_iframe").attr("src",Mindpin.WEB_SITE_COMMENTS_URL);
  },
  
  // 显示历史记录
  show_browse_history : function(){
    $("#mindpin_window_content #browse_history_iframe").attr("src",Mindpin.BROWSE_HISTORIES_URL);
  }
}

$(document).ready(function(){
  Mindpin.MindpinWindow.init();
});
