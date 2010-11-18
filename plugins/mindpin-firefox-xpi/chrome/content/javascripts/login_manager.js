if(typeof(Mindpin)=='undefined'){Mindpin={}}

Mindpin.LoginManager = {
  // 获得登录用户信息，如果没有登录，返回 false
  get_logined_user: function() {
    var name = Mindpin.Preferences.get_unicode("user.name");
    var avatar = Mindpin.Preferences.get_unicode("user.avatar");
    
    if(!name || !avatar){return false}
    
    return {
      'name':name,
      "avatar":avatar
    };
  },

  set_login_user: function(user){
    Mindpin.Preferences.set_unicode("user.name",user.name);
    Mindpin.Preferences.set_unicode("user.avatar",user.avatar);
  },
  remove_login_user: function(){
    Mindpin.Preferences.remove("user.name");
    Mindpin.Preferences.remove("user.avatar");
  },
  
  // 异步登录请求
  asyn_try_login: function() {
    $.ajax({
      url:Mindpin.LOGIN_URL,
      type:"POST",
      dataType:"json",
      success:function(user){
        Mindpin.LoginManager.set_login_user(user)
      },
      error:function(){
        Mindpin.LoginManager.remove_login_user();
      },
      complete:function(){
        Mindpin.MindpinSidebar.check_open_and_show();
      }
    });
  },

  //点击登录按钮后，异步提交表单
  login: function(){
    var hash = this._get_login_hash();
    if(hash){
      $.ajax({
        url: Mindpin.LOGIN_URL,
        type: "POST",
        data: hash,
        dataType: "json",
        beforeSend: function(){
          Mindpin.LoginManager._set_login_info("正在验证用户信息...");
        },
        success: function() {
          Mindpin.LoginManager._set_login_info("验证成功");
        },
        error: function(xhr,stats,response){
          if(xhr.status == 401){
            // 登录失败的回调函数
            Mindpin.LoginManager._set_login_info("登录邮箱或密码错误。");
          }else{
            alert(stats);
            alert(response);
          }
        }
      });
    }
  },
  _get_login_hash:function(){
    var email = $('#tb_email')[0].value;
    var password = $('#tb_password')[0].value;
    var remember_me = $('#remember_me')[0].checked;

    // 邮箱不能为空
    if(email == "") {
      this._set_login_info("提示：请输入登录邮箱");
      $('#tb_email')[0].focus();
      return null;
    }
    // 密码不能为空
    if(password == "") {
      this._set_login_info("提示：请输入密码");
      $('#tb_password')[0].focus();
      return null;
    }

    var hash={
      'email':email,
      'password':password,
      'remember_me':remember_me
    };

    return hash;
  },
  _set_login_info:function(str){
    getSidebarWindow().$('#login_info').attr('value',str);
  },


  logout: function() {
    $.ajax({
      url: Mindpin.LOGOUT_URL,
      type: "GET"
    });
  },
  
  // 取消登录框
  cancel: function() {
    window.close();
  },
  // 删除 网站的 cookies
  remove_cookies: function(){
    var cs = Components.classes["@mozilla.org/cookiemanager;1"]
          .getService(Components.interfaces.nsICookieManager)
    cs.remove(".2010.mindpin.com","_mindpin_2010_session_dev","/",false);
    cs.remove(".2010.mindpin.com","_mindpin_2010_session","/",false);
    cs.remove(".2010.mindpin.com","token","/",false);
    cs.remove(".2010.mindpin.com","logged_in_for_plugin","/",false);
  },
  // 获得 网站的 cookies
  get_cookies: function(){
    var cookie_str = ""
    var cookieMgr = Components.classes["@mozilla.org/cookiemanager;1"]
               .getService(Components.interfaces.nsICookieManager);
    for (var e = cookieMgr.enumerator; e.hasMoreElements();) {
      var cookie = e.getNext().QueryInterface(Components.interfaces.nsICookie); 
      if(cookie.host == '.2010.mindpin.com'){
        cookie_str += (cookie.name + "=" + cookie.value + ";")
      }
    }
    return cookie_str
  }

};