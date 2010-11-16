var BG = chrome.extension.getBackgroundPage();
if(typeof(BG.Mindpin)=='undefined'){
  BG.Mindpin = {}
}
var Mindpin = BG.Mindpin;

Mindpin.LoginWindow = {
  init: function(){
    $("#user_submit").click(function(evt){
      evt.preventDefault();
      Mindpin.LoginWindow.login();
    });
  },
  login: function(){
    $("#tip").hide();
    var email = $("#user_email").attr("value");
    var password = $("#user_password").attr("value");
    if(email == ""){
      $("#tip").text("请输入登录邮箱");
      $("#tip").show();
      $("#user_email")[0].focus();
      return;
    }

    if(password == ""){
      $("#tip").text("请输入登录密码");
      $("#tip").show();
      $("#user_password")[0].focus();
      return;
    }

    $("#tip").text("正在提交..");
    $("#tip").show();

    var data_hash = {email:email,password:password}
    if($("#remember_me").attr("checked")){
      data_hash.remember_me = "on"
    }
    
    $.ajax({
      url:Mindpin.LOGIN_URL,
      type:"POST",
      dataType:"json",
      data: data_hash,
      success:function(user){
        Mindpin.UserManager.set_user(user);
        window.close();
      },
      error:function(){
        $("#tip").text("用户名或密码错误");
        $("#tip").show();
      }
    });

  }
}

$(document).ready(function(){
  Mindpin.LoginWindow.init();
});


