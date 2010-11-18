if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
}
Mindpin.TListener = {
  QueryInterface: function(aIID) {  
    if (aIID.equals(Components.interfaces.nsIWebProgressListener) ||  
      aIID.equals(Components.interfaces.nsISupportsWeakReference) ||
      aIID.equals(Components.interfaces.nsISupports))
      return this;  
    throw Components.results.NS_NOINTERFACE;  
  },
  onLocationChange: function(aProgress, aRequest, aURI){
    // 如果是新打开的网页，注册发送历史记录的异步请求
    if(typeof(aProgress.DOMWindow._add_mindpin_history_listener) == "undefined"){
      aProgress.DOMWindow.document.addEventListener("DOMContentLoaded",
        function(){
          Mindpin.MindpinSidebar.asyn_post_browse_history();
          if(Mindpin.MindpinSidebar.is_open() && Mindpin.LoginManager.get_logined_user()){
            setTimeout(Mindpin.MindpinSidebar.show_current_page_content,0)
          }
        }
        ,false);
      aProgress.DOMWindow._add_mindpin_history_listener = true
    }

    if(Mindpin.MindpinSidebar.is_open()){
      Mindpin.MindpinSidebar.loading_ui();
      Mindpin.MindpinSidebar.show();
    }
  },
  onStateChange: function(aWebProgress, aRequest, aFlag, aStatus){},
  onProgressChange: function(aWebProgress, aRequest, curSelf, maxSelf, curTot, maxTot) {},  
  onStatusChange: function(aWebProgress, aRequest, aStatus, aMessage) {},  
  onSecurityChange: function(aWebProgress, aRequest, aState) {}
};

Mindpin.CookieListener = function() {
  this.os = Components.classes["@mozilla.org/observer-service;1"].getService(Components.interfaces.nsIObserverService);
  this._register();
};

Mindpin.CookieListener.prototype = {
  _register: function(){
    this.os.addObserver(this, "cookie-changed", false);
  },
  _unregister: function(){
    this.os.removeObserver(this, "cookie-changed");
  },
  observe: function(subject, topic, data) {
    var lm = Mindpin.LoginManager;

    if(data == "cleared"){
      return setTimeout(lm.asyn_try_login,0)
    }

    var cookie = subject.QueryInterface(Components.interfaces.nsICookie);
    if(cookie.host == ".2010.mindpin.com" && cookie.name == "logged_in_for_plugin"){
      if((cookie.value != this.logged_in_for_plugin) || data != "changed"){
        this.logged_in_for_plugin = cookie.value;
        setTimeout(lm.asyn_try_login,0)
      }
    }
  }
};

function mindpin_init(){

  // 地址栏后面显示图标
  var mindpin_bar = window.document.createElement("toolbaritem");
  mindpin_bar.setAttribute("id","status-bar");
  mindpin_bar.setAttribute("class","chromeclass-toolbar-additional");
  var label = window.document.createElement("label");
  label.setAttribute("id","status-bar-img");
  label.setAttribute("class","close_status");
  label.setAttribute("onclick","toggleSidebar('mindpin_siderbar');");
  mindpin_bar.appendChild(label);
  $(mindpin_bar).insertAfter($("#urlbar-container"));
  
  var content = $("#content")[0];
  content.addProgressListener(Mindpin.TListener);
  Mindpin.LoginManager.asyn_try_login();
  new Mindpin.CookieListener();
};

window.addEventListener("load", mindpin_init, false);