if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
}

Mindpin.UserManager = {
  get_user: function(){
    return JSON.parse(localStorage.getItem("user"));
  },
  set_user: function(user){
    localStorage.setItem("user",JSON.stringify(user));
  },
  remove_user: function(){
    localStorage.removeItem("user");
  },
  prompt_user_login: function(){
    window.open("login_window.html", "LoginWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
  },
  asyn_try_login: function(){
    $.ajax({
      url:Mindpin.LOGIN_URL,
      type:"POST",
      dataType:"json",
      success:function(user){
        Mindpin.UserManager.set_user(user)
      },
      error:function(){
        Mindpin.UserManager.remove_user();
      },
      complete:function(){
        if(MindpinWin){
          console.log(MindpinWin)
          MindpinWin.window.MindpinWindow.check_open_and_show();
        }
      }
    });
  },
  logout: function(){
    $.ajax({
      url: Mindpin.LOGOUT_URL,
      type: "get"
    });
  }
}

