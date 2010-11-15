if(typeof(Mindpin)=='undefined'){Mindpin = {}}

Mindpin.UserManager = {
  get_user: function(){
    return null;
  },
  set_user: function(user){
    return null;
  },
  remove_user: function(){
    return null;
  },
  prompt_user_login: function(){
    window.open("login_window.html", "LoginWindow", "location=no,height=100, width=400,centerscreen,modal,resizable=no");
  },
  asyn_try_login: function(email,password){
    $.ajax({
      url:Mindpin.LOGIN_URL,
      type:"POST",
      dataType:"json",
      success:function(user){
        Mindpin.UserManager.set_user(user)
      },
      error:function(){
        Mindpin.LoginManager.remove_user();
      },
      complete:function(){
        Mindpin.MindpinWindow.check_open_and_show();
      }
    });
  }
}

