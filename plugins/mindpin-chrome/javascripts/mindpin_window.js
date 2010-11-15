var BG = chrome.extension.getBackgroundPage();
if(typeof(BG.Mindpin)=='undefined'){BG.Mindpin = {}}
var Mindpin = BG.Mindpin;

Mindpin.MindpinWindow = {
  init: function(){
    // 注册一些事件
    this.loading_ui();
    this.add_events();
    var user = Mindpin.UserManager.get_user();
    if(user){
      this.logined_ui(user);
    }else{
      this.unlogin_ui();
    }
  },

  add_events: function(){
    // 退出登录按钮
    $("#logout").click(function(evt){
      alert("退出")
      evt.preventDefault();
    });

    // 登录按钮
    $("#login").click(function(evt){
      Mindpin.UserManager.prompt_user_login();
      evt.preventDefault();
    });
    // 注册按钮
    $("#register").click(function(evt){
      alert("注册")
      evt.preventDefault();
    });
  },
  
  loading_ui: function(){
    
  },
  logined_ui: function(){
    
  },
  unlogin_ui: function(){
    $("#logined_action",document).hide();
    $("#unlogin_action",document).show();
  },
  check_open_and_show: function(){
    
  },
  login: function(){

  },
  logout: function(){
    
  }
}

$(document).ready(function(){
  Mindpin.MindpinWindow.init();
});
