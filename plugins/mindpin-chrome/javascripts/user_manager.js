if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
  }

Mindpin.UserManager = {
  get_user: function(){
    var name = localStorage.getItem("user_name")
    var avatar = localStorage.getItem("user_avatar")
    if(name){
      return {
        name:name,
        avatar:avatar
      }
    }
    return null;
  },
  set_user: function(user){
    localStorage.setItem("user_name",user.name);
    localStorage.setItem("user_avatar",user.avatar);
  },
  remove_user: function(){
    localStorage.removeItem("user_name");
    localStorage.removeItem("user_avatar");
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
          Mindpin.MindpinWindow.check_open_and_show();
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

