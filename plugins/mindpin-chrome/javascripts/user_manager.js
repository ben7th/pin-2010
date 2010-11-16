if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
  }

Mindpin.UserManager = {
  get_user: function(){
    var name = localStorage.getItem("user_name")
    if(name){
      return {
        name:name
      }
    }
    return null;
  },
  set_user: function(user){
    localStorage.setItem("user_name",user.name);
  },
  remove_user: function(){
    localStorage.removeItem("user_name");
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

